import os
from pathlib import Path


def _load_optional_env_file():
    env_path = Path(__file__).with_name('.env')
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = line.split('=', 1)
        key = key.strip()
        value = value.strip().strip('"\'')
        os.environ.setdefault(key, value)


_load_optional_env_file()


class Config:
    host = os.getenv('AI_HOST', '127.0.0.1')
    port = int(os.getenv('AI_PORT', '8000'))
    secret = os.getenv('AI_SERVICE_SECRET', '')
    token = os.getenv('AI_SERVICE_TOKEN', '')
    log_level = os.getenv('LOG_LEVEL', 'INFO')
    model_name = os.getenv('MODEL_NAME', 'sustainability-scorer')


config = Config()
