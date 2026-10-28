# Activity 10 - Endpoint test log (KopraGrade)

Run: `uvicorn app.main:app --host 127.0.0.1 --port 8000` from `backend/`; tested in Swagger UI (/docs).

| ID | Method | Path | HTTP |
|---|---|---|---|
| F01 | POST | /api/auth/register | 201 |
| F02 | POST | /api/auth/register | 201 |
| F03 | POST | /api/auth/login | 200 |
| F04 | GET | /api/users/me | 200 |
| F05 | PUT | /api/users/me | 200 |
| F06 | GET | /api/users/me | 200 |
| F07 | POST | /api/classification/predict | 201 |
| F08 | GET | /api/gradings/1 | 200 |
| F09 | GET | /api/history | 200 |
| F10 | GET | /api/history?grade=Well-Dried&limit=5 | 200 |
| F11 | GET | /api/health | 200 |
| F12 | GET | /api/history (buyer) | 200 |
| F13 | GET | /api/gradings/1 (buyer) | 200 |
| N01 | POST | /api/auth/register (duplicate) | 409 |
| N02 | POST | /api/auth/login (bad password) | 401 |
| N03 | GET | /api/users/me (no token) | 401 |
| N04 | GET | /api/gradings/999999 | 404 |
| N05 | POST | /api/classification/predict (buyer) | 403 |
| N06 | GET | /api/gradings/1 (other farmer) | 403 |

GET /health -> 200 {"status":"ok"} (E01 fixed). pytest: 40 passed.
