# setup_utils.py
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# Load environment variables
load_dotenv(verbose=True, encoding='utf-8')

def setup_db_connection():
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    db_host = os.getenv("DB_HOST")
    db_port = os.getenv("DB_PORT")
    db_name = os.getenv("DB_NAME")

    db_conn_string = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    db_conn_query = """
    select implementation_info_name key, character_value as value
    from mimiciv.information_schema.sql_implementation_info
    where implementation_info_name like 'DBMS %'
    """

    try:
        engine = create_engine(db_conn_string)
        with engine.connect() as conn:
            conn.execute(text(db_conn_query))
        return engine
    except Exception as e:
        raise e
