# Horse Racing Database System  
### ICS321 — Database Systems Project

---

## Group Information  
**Group Number:** F11  
**Group Members:**  
- Aleen Alghamdi — *202244260*  
- Khawla Almalki — *202247320*

---

## Overview
The **Horse Racing Database System** is a web-based application developed for **ICS321 – Database Systems**.  
It allows users to manage and analyze horse racing data efficiently through two main interfaces:

- **Admin Panel** – complete control for adding races, deleting owners, approving trainers, and managing data.  
- **Guest Portal** – view and search horse and race information easily.

The system uses a **MySQL database**, **Node.js + Express** backend, and a **modern responsive frontend**.

---

## Features
### Admin Panel
- Delete owners and all related records (via stored procedure)  
- Automatically back up deleted horses into `Old_Info` (via trigger)  
- Add new races and race results  
- Move horses to new stables  
- Approve new trainers  
- View database tables interactively  

### Guest Portal
- Search horses by owner name  
- View winning trainers, race stats, and rankings  

---

## Database Logic
- **Stored Procedure:** `DeleteOwner()` → deletes an owner and all related data  
- **Trigger:** `trg_backup_horse` → copies deleted horse data to `Old_Info`  
- **Foreign Key Constraints** → ensure referential integrity  

---

## Project Structure
```
horse_db/
│
├── server.js                 # Backend (Express + MySQL)
├── package.json              # Dependencies & scripts
├── ICS321 Project 1 DB.sql    # All SQL tables, data, procedure & trigger
├── README.md
└── public/
    ├── index.html            # Landing page
    ├── admin.html            # Admin panel
    ├── guest.html            # Guest page
    ├── /css/
    │   └── style.css
    └── image.jpg
    

      
```

---

## Database Setup

1. Open **MySQL Workbench**.  
2. Create a new database and import the provided SQL:
   ```sql
   SOURCE ICS321 Project 1 DB.sql;
   ```
3. This will create:
   - Tables (`Owner`, `Horse`, `Race`, `Stable`, `Trainer`, `Old_Info`)
   - Data records
   - Stored procedure (`DeleteOwner`)
   - Trigger (`trg_backup_horse`)

---

## Running the System

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Database Credentials
Inside `server.js`:
```js
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'Admin123',
  database: 'RACING'
});
```

### 3. Run the Server
```bash
node server.js
```

### 4. Open in Browser
```
http://localhost:3000
```

---

## Testing Functionality

| Feature | Page | Description |
|----------|------|-------------|
| Delete Owner | Admin | Deletes owner and related horses, races, and trainers |
| Add Race | Admin | Adds race info and horse results |
| Move Horse | Admin | Updates stable for given horse |
| Approve Trainer | Admin | Adds new trainer to system |
| Search Horses | Guest | Finds horses by owner last name |
| View Data | Both | Displays live DB data in tables |

---

## Tools & Technologies
| Category | Tools Used |
|-----------|-------------|
| Backend | Node.js, Express |
| Database | MySQL |
| Frontend | HTML5, CSS3, JavaScript |
| Design | Custom responsive UI |
| Environment | WebStorm |

---
