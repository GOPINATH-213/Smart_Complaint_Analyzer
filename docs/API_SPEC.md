# API Specification (Endpoints Reference)

This document specifies the REST API endpoints, payload configurations, and response conventions for Phase 1.

---

## 1. Global Specifications

* **Base URL**: `/api/users`
* **Content Type**: `application/json`
* **Authentication**: Firebase ID Tokens passed via Authorization Header in future phases:
  `Authorization: Bearer <firebase_id_token>`

---

## 2. API Endpoints

### 1. Sync User Auth Details
Registers or syncs basic login data to MongoDB upon successful client sign-in.

* **URL**: `/sync`
* **Method**: `POST`
* **Payload**:
  ```json
  {
    "firebaseUID": "xZ81Jdla923hdka9",
    "email": "910623104026@klnce.edu",
    "role": "Student",
    "name": "Arun Kumar",
    "emailVerified": false,
    "registerNumber": "910623104026"
  }
  ```
* **Success Response (201 Created / 200 OK)**:
  ```json
  {
    "success": true,
    "message": "User synced successfully",
    "data": {
      "firebaseUID": "xZ81Jdla923hdka9",
      "role": "Student",
      "email": "910623104026@klnce.edu",
      "emailVerified": false,
      "name": "Arun Kumar",
      "department": "Not Assigned",
      "registerNumber": "910623104026",
      "year": "I Year"
    }
  }
  ```

### 2. Retrieve User Profile
Fetches a user's full database profile.

* **URL**: `/profile/:firebaseUID`
* **Method**: `GET`
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "firebaseUID": "xZ81Jdla923hdka9",
      "role": "Student",
      "name": "Arun Kumar",
      "email": "910623104026@klnce.edu",
      "phone": "9876543210",
      "department": "CSE",
      "year": "III Year",
      "registerNumber": "910623104026"
    }
  }
  ```

### 3. Update User Profile
Updates optional or missing profile fields.

* **URL**: `/profile/:firebaseUID`
* **Method**: `PUT`
* **Payload**:
  ```json
  {
    "name": "Arun Kumar M",
    "phone": "9876543210",
    "department": "CSE",
    "year": "III Year"
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Profile updated successfully",
    "data": {
      "firebaseUID": "xZ81Jdla923hdka9",
      "role": "Student",
      "name": "Arun Kumar M",
      "email": "910623104026@klnce.edu",
      "phone": "9876543210",
      "department": "CSE",
      "year": "III Year"
    }
  }
  ```

---

## 3. Standard Error Format
All API errors return a standard JSON structure to simplify parsing on the client side:
```json
{
  "success": false,
  "message": "Error description details here",
  "errors": [
    {
      "field": "phone",
      "msg": "Enter a valid 10-digit number"
    }
  ]
}
```
