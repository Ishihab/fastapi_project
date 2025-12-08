import os

print(os.getenv("DB_USER"))
print(os.getenv("DB_PASS"))
print(os.getenv("DB_URL"))
print(os.getenv("DB_NAME"))
print(f"mysql+aiomysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@{os.getenv('DB_URL')}/{os.getenv('DB_NAME')}")
