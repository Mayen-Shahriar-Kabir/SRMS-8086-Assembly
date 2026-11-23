# SRMS-8086-Assembly

## Overview
A terminal-based Student Result Management System (SRMS) written entirely in x86 Assembly language. It utilizes standard DOS interrupts (`INT 21H`, `INT 10H`) for I/O operations and screen management, storing records dynamically in parallel memory arrays.

## Features
* **Role-Based Authentication:** Secure login system branching to role-specific dashboards. Admin access is pre-configured with the ID `admin` and password `admin123`.
* **Record Management:** Admins can register up to 100 students (allocating 30 characters for names and 10 for passwords). Admins can input and update marks (0-100) for three hardcoded subjects: English, Mathematics, and Science.
* **Automated Grade Calculation:** Evaluates parallel mark arrays, calculates the average by dividing the aggregated sum, and assigns letter grades ranging from A+ to F using conditional branching.
* **Performance Analysis:** Students can view subject-wise analytics. The system iterates through the marks array to determine and display the highest, lowest, and average scores.
* **Record Deletion:** Admins can perform a linear search by student ID to delete records. Deletion triggers a memory shift, moving all subsequent elements in the ID, Name, Marks, and Grade arrays to prevent fragmentation.
* **Merit List Generation:** Calculates the average marks of all registered students and sorts them in descending order using a Bubble Sort algorithm. Displays a formatted, ranked leaderboard.

## Tech Stack & Architecture
* **Language:** 16-bit x86 Assembly (`.MODEL SMALL`).
* **Data Structures:** Fixed-size parallel arrays for storing IDs, Names, Passwords, Subject Marks, and Grades.
* **Environment:** Compatible with DOSBox, EMU8086, or TASM/MASM assemblers.

## How to Run
1. Install an x86 emulator like DOSBox or EMU8086.
2. Compile `studentResultManagement.asm` using your assembler (e.g., `TASM` or `MASM`).
3. Link the generated object file to create the executable.
4. Run the `.exe` file in your DOS environment.
