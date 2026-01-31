from fastapi import FastAPI, APIRouter, File, UploadFile, Form, HTTPException
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
import uuid
from datetime import datetime, timezone
import tempfile
import asyncio
from emergentintegrations.llm.openai import OpenAISpeechToText
from openai import AsyncOpenAI


ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client_db = AsyncIOMotorClient(mongo_url)
db = client_db[os.environ['DB_NAME']]

# Initialize AI services
stt_service = OpenAISpeechToText(api_key=os.getenv("EMERGENT_LLM_KEY"))
openai_client = AsyncOpenAI(api_key=os.getenv("EMERGENT_LLM_KEY"))

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")


# Define Models
class CallRecord(BaseModel):
    """Model for call analysis record"""
    model_config = ConfigDict(extra="ignore")
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    phoneNumber: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    riskCategory: str  # SAFE, SUSPICIOUS, FRAUD
    fraudScore: int  # 0-100
    reason: str
    transcript: Optional[str] = None


class FraudAnalysisResult(BaseModel):
    """AI analysis result from GPT"""
    fraud_score: int
    category: str
    reason: str


# Add your routes to the router instead of directly to app
@api_router.get("/")
async def root():
    return {"message": "Fraud Detection API v1.0"}


@api_router.get("/health")
async def health_check():
    """Health check endpoint for Flutter app"""
    return {"status": "ok", "message": "Backend is running"}


@api_router.post("/analyze-call")
async def analyze_call(
    audio: UploadFile = File(...),
    phone_number: str = Form(...)
):
    """
    Analyze a call recording for fraud
    
    Steps:
    1. Receive audio file from Flutter app
    2. Transcribe audio using Whisper
    3. Analyze transcript using GPT-4 for fraud detection
    4. Return structured result
    """
    temp_file_path = None
    
    try:
        # Save uploaded file to temp location
        with tempfile.NamedTemporaryFile(delete=False, suffix=".m4a") as temp_file:
            content = await audio.read()
            temp_file.write(content)
            temp_file_path = temp_file.name
        
        # Step 1: Transcribe audio using Whisper
        logging.info(f"Transcribing audio for {phone_number}")
        
        with open(temp_file_path, "rb") as audio_file:
            transcription_response = await stt_service.transcribe(
                file=audio_file,
                model="whisper-1",
                response_format="text",
                language=None  # Auto-detect (Hindi or English)
            )
        
        transcript = transcription_response.text
        logging.info(f"Transcription completed. Length: {len(transcript)} characters")
        
        # Step 2: Analyze transcript for fraud using GPT-4
        fraud_result = await analyze_fraud_with_gpt(transcript, phone_number)
        
        # Step 3: Create and save call record
        call_record = CallRecord(
            phoneNumber=phone_number,
            riskCategory=fraud_result.category,
            fraudScore=fraud_result.fraud_score,
            reason=fraud_result.reason,
            transcript=transcript
        )
        
        # Save to MongoDB (excluding _id)
        doc = call_record.model_dump()
        doc['timestamp'] = doc['timestamp'].isoformat()
        await db.call_records.insert_one(doc)
        
        # Return result to Flutter app
        return call_record
        
    except Exception as e:
        logging.error(f"Error analyzing call: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")
    
    finally:
        # Clean up temp file
        if temp_file_path and os.path.exists(temp_file_path):
            os.unlink(temp_file_path)


async def analyze_fraud_with_gpt(transcript: str, phone_number: str) -> FraudAnalysisResult:
    """
    Use GPT-4 to analyze transcript for fraud patterns
    
    Returns structured JSON with fraud score, category, and reason
    """
    
    # Fraud detection prompt optimized for Indian context
    system_prompt = """You are an expert fraud detection AI specialized in identifying phone scams targeting senior citizens in India.

Common fraud patterns to detect:
- OTP/PIN requests
- Bank account details requests
- Threats or urgency tactics
- Impersonation (bank officials, government, police, relatives)
- Prize/lottery scams
- KYC update requests
- Fake customer support
- Investment scams

Analyze the call transcript and return a JSON response with:
{
  "fraud_score": <0-100 integer>,
  "category": "<SAFE|SUSPICIOUS|FRAUD>",
  "reason": "<short explanation in simple English suitable for senior citizens>"
}

Scoring guidelines:
- 0-30: SAFE (normal conversation)
- 31-70: SUSPICIOUS (some red flags, be cautious)
- 71-100: FRAUD (clear fraud indicators, do not comply)"""

    user_prompt = f"""Analyze this phone call transcript:

Phone Number: {phone_number}
Transcript: {transcript}

Return fraud analysis in JSON format."""

    try:
        response = await openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            response_format={"type": "json_object"},
            temperature=0.3
        )
        
        result_json = response.choices[0].message.content
        import json
        result = json.loads(result_json)
        
        return FraudAnalysisResult(
            fraud_score=result["fraud_score"],
            category=result["category"],
            reason=result["reason"]
        )
        
    except Exception as e:
        logging.error(f"GPT analysis error: {str(e)}")
        # Fallback result on error
        return FraudAnalysisResult(
            fraud_score=50,
            category="SUSPICIOUS",
            reason="Could not analyze call. Please review manually."
        )


@api_router.get("/call-history", response_model=List[CallRecord])
async def get_call_history():
    """Get all analyzed call records"""
    try:
        records = await db.call_records.find({}, {"_id": 0}).sort("timestamp", -1).to_list(100)
        
        # Convert ISO string timestamps back to datetime
        for record in records:
            if isinstance(record['timestamp'], str):
                record['timestamp'] = datetime.fromisoformat(record['timestamp'])
        
        return records
    except Exception as e:
        logging.error(f"Error fetching call history: {str(e)}")
        return []

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client_db.close()