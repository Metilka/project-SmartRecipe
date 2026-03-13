import os 
from dotenv import load_dotenv
load_dotenv()

class Config:
    SQLALCHEMY_DATABASE_URI = "postgresql://postgres:password@localhost:5432/med_diet_db"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    
