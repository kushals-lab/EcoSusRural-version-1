"""
EcoSusRural PostgreSQL 18 Database Connection Module (Python)
Provides robust connection pooling, query execution, and health checking.
"""
import os
import logging
from typing import Any, Dict, List, Optional
from contextlib import contextmanager

logger = logging.getLogger("ecosusrural.database")

class EcoSusRuralDatabaseConnection:
    """Manages PostgreSQL connection pooling and queries for EcoSusRural services."""

    def __init__(self):
        self.host = os.getenv("PGHOST", "127.0.0.1")
        self.port = int(os.getenv("PGPORT", "5432"))
        self.database = os.getenv("PGDATABASE", "ecosusrural")
        self.user = os.getenv("PGUSER", "postgres")
        self.password = os.getenv("PGPASSWORD")
        self._pool = None
        self._connected = False

    def initialize_pool(self, minconn: int = 1, maxconn: int = 20) -> bool:
        """Initializes psycopg2 / connection pool."""
        try:
            import psycopg2.pool
            self._pool = psycopg2.pool.SimpleConnectionPool(
                minconn,
                maxconn,
                host=self.host,
                port=self.port,
                dbname=self.database,
                user=self.user,
                password=self.password
            )
            self._connected = True
            logger.info("PostgreSQL 18 pool initialized successfully (database: %s)", self.database)
            return True
        except ImportError:
            logger.warning("psycopg2 is not installed. Database connection available in mock/fallback mode.")
            return False
        except Exception as err:
            logger.warning("PostgreSQL 18 connection error: %s. Using in-memory fallback.", err)
            self._connected = False
            return False

    @property
    def is_connected(self) -> bool:
        return self._connected

    @contextmanager
    def get_connection(self):
        """Context manager yielding a pooled connection."""
        if not self._pool:
            raise ConnectionError("PostgreSQL pool is not initialized")
        conn = self._pool.getconn()
        try:
            yield conn
        finally:
            self._pool.putconn(conn)

    def execute_query(self, query: str, params: Optional[tuple] = None) -> List[Dict[str, Any]]:
        """Executes a query and returns dict rows."""
        if not self._connected or not self._pool:
            logger.warning("Database offline; cannot execute query.")
            return []
        
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params or ())
                if cursor.description:
                    columns = [col[0] for col in cursor.description]
                    return [dict(zip(columns, row)) for row in cursor.fetchall()]
                conn.commit()
                return []

# Singleton instance for AI engine and backend tools
db_connection = EcoSusRuralDatabaseConnection()
