import os
from sqlalchemy import create_engine, text
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def reset_database():
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        logger.error("DATABASE_URL environment variable is not set.")
        return

    logger.info("Starting database reset...")
    
    try:
        engine = create_engine(database_url)
        with engine.connect() as connection:
            # Drop the public schema and everything in it
            logger.info("Dropping public schema...")
            connection.execute(text("DROP SCHEMA public CASCADE;"))
            
            # Recreate the public schema
            logger.info("Recreating public schema...")
            connection.execute(text("CREATE SCHEMA public;"))
            
            # Grant permissions (optional but good practice)
            connection.execute(text("GRANT ALL ON SCHEMA public TO public;"))
            connection.execute(text("GRANT ALL ON SCHEMA public TO current_user;"))
            
            connection.commit()
            
        logger.info("Database reset successfully.")
        
    except Exception as e:
        logger.error(f"Error resetting database: {e}")
        raise

if __name__ == "__main__":
    reset_database()
