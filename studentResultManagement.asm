.MODEL SMALL
.STACK 100H


MAX_STUDENTS        EQU 100
STUDENT_NAME_LEN    EQU 30
STUDENT_ID_LEN      EQU 10
STUDENT_PASS_LEN    EQU 10
SUBJECT_COUNT       EQU 3


.DATA

; --- System Messages ---
system_name    DB  'Student Result Management System', 13, 10, '$'
welcome_msg    DB  'Welcome to SRMS!', 13, 10, '$'
line           DB  '=========================================', 13, 10, '$'

; --- Main Menu ---
menu_title     DB  'MAIN MENU', 13, 10, '$'
option1        DB  '1. Register New Student', 13, 10, '$'
option2        DB  '2. Login', 13, 10, '$'
option3        DB  '3. Exit', 13, 10, '$'
choice_prompt  DB  'Enter your choice (1-3): $'

; --- Admin Credentials ---
admin_id       DB  'admin$'
admin_pass     DB  'admin123$'

; --- Registration Messages ---
reg_title      DB  'USER REGISTRATION', 13, 10, '$'
reg_name_prompt DB  'Enter Name (max 29 chars): $'
reg_id_prompt  DB  'Enter ID (max 9 chars): $'
reg_pass_prompt DB 'Enter Password (max 9 chars): $'
reg_success    DB  'Registration successful!', 13, 10, '$'
reg_failed     DB  'Registration failed!', 13, 10, '$'
reg_id_exists  DB  'ID already exists!', 13, 10, '$'
reg_max_reached DB 'Maximum students reached!', 13, 10, '$'

; --- Login Messages ---
login_title    DB  'USER LOGIN', 13, 10, '$'
login_id_prompt DB 'Enter ID: $'
login_pass_prompt DB 'Enter Password: $'
login_success  DB  'Login successful!', 13, 10, '$'
login_failed   DB  'Invalid ID or Password!', 13, 10, '$'

; --- Dashboard Messages ---
admin_role_msg   DB  'Role: ADMIN', 13, 10, '$'
student_role_msg DB  'Role: STUDENT', 13, 10, '$'

; --- Admin Dashboard ---
admin_dashboard_title DB  'ADMIN DASHBOARD', 13, 10, '$'
admin_welcome_msg     DB  'Welcome, Administrator!', 13, 10, '$'
admin_option1    DB  '1. Add Student (via Registration)', 13, 10, '$'
admin_option2    DB  '2. Update Student Marks', 13, 10, '$'
admin_option3    DB  '3. View Student Result (Grade)', 13, 10, '$'
admin_option4    DB  '4. Delete Student Record', 13, 10, '$'
admin_option5    DB  '5. Generate Merit List', 13, 10, '$'
admin_option6    DB  '6. Logout', 13, 10, '$'
admin_choice_prompt DB 'Enter your choice (1-6): $'

; --- Student Dashboard ---
student_dashboard_title DB 'STUDENT DASHBOARD', 13, 10, '$'
student_welcome  DB  'Welcome, $'
student_id_label DB  'Student ID: $'
dashboard_option1 DB '1. View Result (Grade)', 13, 10, '$'
dashboard_option2 DB '2. Analyse Performance', 13, 10, '$'
dashboard_option3 DB '3. Logout', 13, 10, '$'
dashboard_choice DB 'Enter your choice (1-3): $'

; --- Marks Update ---
update_marks_title DB 'UPDATE MARKS', 13, 10, '$'
subject1_name    DB  'English (0-100): $'
subject2_name    DB  'Mathematics (0-100): $'
subject3_name    DB  'Science (0-100): $'
enter_marks_msg  DB  'Enter marks: $'
invalid_marks_msg DB 'Invalid! Enter 0-100: $'

; --- Result Display ---
result_title     DB  'STUDENT RESULT', 13, 10, '$'
grade_label      DB  'Grade: $'
avg_label        DB  'Average Marks: $'

; --- Performance Analysis ---
perf_title       DB  'SUBJECT-WISE PERFORMANCE ANALYSIS', 13, 10, '$'
highest_label    DB  'Highest: $'
lowest_label     DB  'Lowest: $'
average_label    DB  'Average: $'
class_label      DB  'Class Size: $'
no_data_msg      DB  'No student data available!', 13, 10, '$'

; For enhanced merit list 
merit_title         DB  'MERIT LIST (Students by Average Marks)', 13, 10, '$'
student_averages    DB MAX_STUDENTS DUP(0)    ; Pre-calculated averages
sorted_list         DW MAX_STUDENTS DUP(0)    ; Sorted student indices
merit_header_line   DB 'Rank  Name                     Avg  Grade', 13, 10, '$'
merit_divider       DB '----  -----------------------  ---  -----', 13, 10, '$'

; Utility variables
temp_swap_buffer    DB STUDENT_NAME_LEN DUP('$')
temp_rank           DW 0

; --- Utility Messages ---
press_key_msg    DB  'Press any key to continue...$'
newline          DB  13, 10, '$'
searching_msg    DB  'Searching...', 13, 10, '$'
found_msg        DB  'Found!', 13, 10, '$'
not_found_msg    DB  'Not found!', 13, 10, '$'

; --- Search/Update ---
search_id_prompt DB  'Enter Student ID to search: $'
delete_confirm   DB  'Delete this student? (Y/N): $'
delete_success   DB  'Student deleted successfully!', 13, 10, '$'
update_success   DB  'Update successful!', 13, 10, '$'
logout_msg       DB  'Logged out successfully!', 13, 10, '$'

; --- Input Buffers ---
input_id         DB  12 DUP('$')
input_pass       DB  12 DUP('$')
input_name       DB  32 DUP('$')
search_id_buffer DB  12 DUP('$')
temp_marks       DB  0
temp_marks_acc   DW  0
marks_line_buf   DB  3, 0, 4 DUP(0)  ; (unused now)

; --- Variables ---
user_choice      DB  ?
user_role        DB  ?  ; '1' = Admin, '2' = Student
login_success_flag DB 0
student_count    DW 0
current_student_index DW 0
temp_index       DW 0

; --- Student Data Arrays ---
student_names    DB MAX_STUDENTS * STUDENT_NAME_LEN DUP('$')
student_ids      DB MAX_STUDENTS * STUDENT_ID_LEN DUP('$')
student_passwords DB MAX_STUDENTS * STUDENT_PASS_LEN DUP('$')

; --- Subject Marks ---
english_marks    DB MAX_STUDENTS DUP(0)
math_marks       DB MAX_STUDENTS DUP(0)
science_marks    DB MAX_STUDENTS DUP(0)

; --- Grade ---
student_grade    DB MAX_STUDENTS DUP('F') ; Letter (A,B,C,D,F)
student_grade_mod DB MAX_STUDENTS DUP(' ') ; '+', '-', or ' ' (space)

; --- Display Variables ---
temp_num         DB 0
current_name     DB STUDENT_NAME_LEN DUP('$')
current_id       DB STUDENT_ID_LEN DUP('$')


.CODE

MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX
    
    ; Main Program Loop
MAIN_LOOP:
    CALL CLEAR_SCREEN
    CALL DISPLAY_WELCOME
    CALL DISPLAY_MENU
    CALL GET_CHOICE
    
    CMP user_choice, '1'
    JE REGISTER_USER
    
    CMP user_choice, '2'
    JE LOGIN_USER
    
    CMP user_choice, '3'
    JE EXIT_PROGRAM
    
    JMP MAIN_LOOP

REGISTER_USER:
    CALL REGISTRATION_PROCESS
    JMP MAIN_LOOP

LOGIN_USER:
    CALL LOGIN_PROCESS
    CMP login_success_flag, 1
    JE REDIRECT_TO_DASHBOARD
    JMP MAIN_LOOP

REDIRECT_TO_DASHBOARD:
    CMP user_role, '1'
    JE ADMIN_DASHBOARD_MAIN
    
    CMP user_role, '2'
    JE STUDENT_DASHBOARD_MAIN
    
    JMP MAIN_LOOP

ADMIN_DASHBOARD_MAIN:
    CALL ADMIN_DASHBOARD_PROCESS    
    JMP MAIN_LOOP

STUDENT_DASHBOARD_MAIN:
    CALL STUDENT_DASHBOARD_PROCESS
    JMP MAIN_LOOP

EXIT_PROGRAM:
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

; SCREEN UTILITIES 

CLEAR_SCREEN PROC
    MOV AX, 0600H
    MOV BH, 07H
    MOV CX, 0000H
    MOV DX, 184FH
    INT 10H
    
    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 0000H
    INT 10H
    
    RET
CLEAR_SCREEN ENDP

DISPLAY_WELCOME PROC
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, system_name
    INT 21H
    
    LEA DX, line
    INT 21H
    
    LEA DX, welcome_msg
    INT 21H
    
    RET
DISPLAY_WELCOME ENDP

DISPLAY_MENU PROC
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, menu_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    LEA DX, option1
    INT 21H
    
    LEA DX, option2
    INT 21H
    
    LEA DX, option3
    INT 21H
    
    LEA DX, line
    INT 21H
    
    RET
DISPLAY_MENU ENDP

GET_CHOICE PROC
    MOV AH, 09H
    LEA DX, choice_prompt
    INT 21H
    
    MOV AH, 01H
    INT 21H
    MOV user_choice, AL
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    RET
GET_CHOICE ENDP

; REGISTRATION 

REGISTRATION_PROCESS PROC
    CALL CLEAR_SCREEN
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, reg_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    MOV AX, student_count
    CMP AX, MAX_STUDENTS
    JL CAN_REGISTER
    
    LEA DX, reg_max_reached
    INT 21H
    JMP REG_END
    
CAN_REGISTER:
    ; Get name
    MOV AH, 09H
    LEA DX, reg_name_prompt
    INT 21H
    
    LEA SI, input_name
    MOV CX, STUDENT_NAME_LEN - 1
    CALL GET_INPUT_STRING_LIMITED
    
    ; Get ID
    MOV AH, 09H
    LEA DX, reg_id_prompt
    INT 21H
    
    LEA SI, input_id
    MOV CX, STUDENT_ID_LEN - 1
    CALL GET_INPUT_STRING_LIMITED
    
    ; Check if ID exists
    CALL CHECK_ID_EXISTS
    CMP AX, 1
    JE ID_EXISTS_ERROR
    
    ; Get password
    MOV AH, 09H
    LEA DX, reg_pass_prompt
    INT 21H
    
    LEA SI, input_pass
    MOV CX, STUDENT_PASS_LEN - 1
    CALL GET_INPUT_STRING_LIMITED
    
    ; Add student
    CALL ADD_STUDENT
    
    MOV AH, 09H
    LEA DX, reg_success
    INT 21H
    JMP REG_END
    
ID_EXISTS_ERROR:
    MOV AH, 09H
    LEA DX, reg_id_exists
    INT 21H
    
REG_END:
    MOV AH, 09H
    LEA DX, press_key_msg
    INT 21H
    
    MOV AH, 01H
    INT 21H
    
    RET
REGISTRATION_PROCESS ENDP

; LOGIN 

LOGIN_PROCESS PROC
    CALL CLEAR_SCREEN
    MOV login_success_flag, 0
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, login_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    ; Get ID
    MOV AH, 09H
    LEA DX, login_id_prompt
    INT 21H
    
    LEA SI, input_id
    CALL GET_INPUT_STRING
    
    ; Get Password
    MOV AH, 09H
    LEA DX, login_pass_prompt
    INT 21H
    
    LEA SI, input_pass
    CALL GET_INPUT_STRING
    
    ; Check Admin
    CALL COMPARE_ADMIN_CREDS
    CMP AX, 1
    JE ADMIN_LOGIN_SUCCESS
    
    ; Check Student
    CALL SEARCH_STUDENT_LOGIN
    CMP AX, 1
    JE STUDENT_LOGIN_SUCCESS
    
    ; Failed
    MOV AH, 09H
    LEA DX, login_failed
    INT 21H
    
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET

ADMIN_LOGIN_SUCCESS:
    MOV user_role, '1'
    MOV login_success_flag, 1
    
    MOV AH, 09H
    LEA DX, login_success
    INT 21H
    
    LEA DX, admin_role_msg
    INT 21H
    
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET

STUDENT_LOGIN_SUCCESS:
    MOV user_role, '2'
    MOV login_success_flag, 1
    
    ; Save current student info
    CALL SAVE_STUDENT_SESSION
    
    MOV AH, 09H
    LEA DX, login_success
    INT 21H
    
    LEA DX, student_role_msg
    INT 21H
    
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
    
LOGIN_PROCESS ENDP

;  STRING UTILITIES 

GET_INPUT_STRING PROC
    ; SI points to buffer
    MOV CX, 0
    
INPUT_LOOP:
    MOV AH, 01H
    INT 21H
    
    CMP AL, 0DH
    JE INPUT_DONE
    
    MOV [SI], AL
    INC SI
    INC CX
    CMP CX, 9
    JL INPUT_LOOP

INPUT_DONE:
    MOV BYTE PTR [SI], '$'
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    RET
GET_INPUT_STRING ENDP

GET_INPUT_STRING_LIMITED PROC
    PUSH AX
    PUSH CX
    PUSH SI
    
    MOV BYTE PTR [SI], '$'
    
INPUT_LOOP_LIMITED:
    MOV AH, 01H
    INT 21H
    
    CMP AL, 0DH
    JE INPUT_DONE_LIMITED
    
    CMP CX, 0
    JLE INPUT_LOOP_LIMITED
    
    MOV [SI], AL
    INC SI
    DEC CX
    JMP INPUT_LOOP_LIMITED

INPUT_DONE_LIMITED:
    MOV BYTE PTR [SI], '$'
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    POP SI
    POP CX
    POP AX
    RET
GET_INPUT_STRING_LIMITED ENDP

STR_CMP PROC
    ; SI = string1, DI = string2
    PUSH CX                 
STR_CMP_LOOP:
    MOV AL, [SI]
    MOV CL, [DI]           
    
    CMP AL, CL
    JNE STR_NOT_EQUAL
    
    CMP AL, '$'
    JE STR_EQUAL
    
    INC SI
    INC DI
    JMP STR_CMP_LOOP

STR_EQUAL:
    POP CX                 
    MOV AX, 1
    RET

STR_NOT_EQUAL:
    POP CX              
    MOV AX, 0
    RET
STR_CMP ENDP

COPY_STRING PROC
    ; SI -> DI
    PUSH AX
COPY_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    CMP AL, '$'
    JE COPY_DONE
    INC SI
    INC DI
    JMP COPY_LOOP
COPY_DONE:
    POP AX
    RET
COPY_STRING ENDP

; ADMIN CREDENTIALS 

COMPARE_ADMIN_CREDS PROC
    LEA SI, input_id
    LEA DI, admin_id
    CALL STR_CMP
    
    CMP AX, 1
    JNE ADMIN_FAIL
    
    LEA SI, input_pass
    LEA DI, admin_pass
    CALL STR_CMP
    
    CMP AX, 1
    JNE ADMIN_FAIL
    
    MOV AX, 1
    RET

ADMIN_FAIL:
    MOV AX, 0
    RET
COMPARE_ADMIN_CREDS ENDP

; STUDENT SEARCH/LOGIN 

CHECK_ID_EXISTS PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV CX, student_count
    CMP CX, 0
    JE ID_NOT_FOUND_CHECK
    
    LEA SI, student_ids
    
CHECK_ID_LOOP:
    LEA DI, input_id
    PUSH BX              
    PUSH SI
    PUSH DI
    CALL STR_CMP
    POP DI
    POP SI
    POP BX
    CMP AX, 1
    JE ID_FOUND_CHECK
    
    ADD SI, STUDENT_ID_LEN
    LOOP CHECK_ID_LOOP
    
ID_NOT_FOUND_CHECK:
    MOV AX, 0
    JMP CHECK_ID_EXIT
    
ID_FOUND_CHECK:
    MOV AX, 1
    
CHECK_ID_EXIT:
    POP DI
    POP SI
    POP CX
    POP BX
    RET
CHECK_ID_EXISTS ENDP

SEARCH_STUDENT_LOGIN PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV CX, student_count
    CMP CX, 0
    JE STUDENT_LOGIN_FAIL
    
    LEA SI, student_ids
    MOV BX, 0
    
SEARCH_LOOP:
    LEA DI, input_id
    PUSH SI
    PUSH DI
    PUSH BX                  ; Saving student index
    CALL STR_CMP
    POP BX                   ; Restoring student index
    POP DI
    POP SI
    CMP AX, 1
    JE FOUND_STUDENT_ID
    
    ADD SI, STUDENT_ID_LEN
    INC BX
    LOOP SEARCH_LOOP
    JMP STUDENT_LOGIN_FAIL
    
FOUND_STUDENT_ID:
    ; Saving the found index
    MOV current_student_index, BX
    
    ; Calculating password array offset
    ; Offset = index * STUDENT_PASS_LEN
    MOV AX, BX               ; AX = student index
    MOV BX, STUDENT_PASS_LEN
    MUL BX                   ; AX = index * pass_len
    
    LEA SI, student_passwords
    ADD SI, AX
    
    LEA DI, input_pass
    CALL STR_CMP
    
    CMP AX, 1
    JNE STUDENT_LOGIN_FAIL
    
    MOV AX, 1
    ; current_student_index
    JMP STUDENT_LOGIN_EXIT
    
STUDENT_LOGIN_FAIL:
    MOV AX, 0
    
STUDENT_LOGIN_EXIT:
    POP DI
    POP SI
    POP CX
    POP BX
    RET
SEARCH_STUDENT_LOGIN ENDP

ADD_STUDENT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    ; Adding name
    MOV AX, student_count
    MOV BX, STUDENT_NAME_LEN
    MUL BX
    LEA DI, student_names
    ADD DI, AX
    
    LEA SI, input_name
    CALL COPY_STRING
    
    ; Adding ID
    MOV AX, student_count
    MOV BX, STUDENT_ID_LEN
    MUL BX
    LEA DI, student_ids
    ADD DI, AX
    
    LEA SI, input_id
    CALL COPY_STRING
    
    ; Adding password
    MOV AX, student_count
    MOV BX, STUDENT_PASS_LEN
    MUL BX
    LEA DI, student_passwords
    ADD DI, AX
    
    LEA SI, input_pass
    CALL COPY_STRING
    
    ; Initializing marks to 0
    MOV SI, student_count
    
    LEA BX, english_marks
    ADD BX, SI
    MOV BYTE PTR [BX], 0
    
    LEA BX, math_marks
    ADD BX, SI
    MOV BYTE PTR [BX], 0
    
    LEA BX, science_marks
    ADD BX, SI
    MOV BYTE PTR [BX], 0
    
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'F'
    
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '
    
    INC student_count
    
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
ADD_STUDENT ENDP

SAVE_STUDENT_SESSION PROC
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI
    
    MOV SI, current_student_index
    
    ; Copying name
    MOV AX, SI
    MOV BX, STUDENT_NAME_LEN
    MUL BX
    LEA SI, student_names
    ADD SI, AX
    LEA DI, current_name
    CALL COPY_STRING
    
    ; Copying ID
    MOV AX, current_student_index
    MOV BX, STUDENT_ID_LEN
    MUL BX
    LEA SI, student_ids
    ADD SI, AX
    LEA DI, current_id
    CALL COPY_STRING
    
    POP DI
    POP SI
    POP BX
    POP AX
    RET
SAVE_STUDENT_SESSION ENDP

; ADMIN DASHBOARD 

ADMIN_DASHBOARD_PROCESS PROC
ADMIN_DASHBOARD_LOOP:
    CALL CLEAR_SCREEN
    CALL DISPLAY_ADMIN_WELCOME
    CALL DISPLAY_ADMIN_MENU
    CALL GET_ADMIN_CHOICE
    
    CMP user_choice, '1'
    JE ADMIN_REGISTER
    
    CMP user_choice, '2'
    JE ADMIN_UPDATE_MARKS
    
    CMP user_choice, '3'
    JE ADMIN_VIEW_RESULT
    
    CMP user_choice, '4'
    JE ADMIN_DELETE_RECORD
    
    CMP user_choice, '5'
    JE ADMIN_MERIT_LIST
    
    CMP user_choice, '6'
    JE ADMIN_LOGOUT
    
    JMP ADMIN_DASHBOARD_LOOP

ADMIN_REGISTER:
    CALL REGISTRATION_PROCESS
    JMP ADMIN_DASHBOARD_LOOP

ADMIN_UPDATE_MARKS:
    CALL ADMIN_UPDATE_STUDENT_MARKS
    JMP ADMIN_DASHBOARD_LOOP

ADMIN_VIEW_RESULT:
    CALL ADMIN_VIEW_STUDENT_RESULT
    JMP ADMIN_DASHBOARD_LOOP

ADMIN_DELETE_RECORD:
    CALL ADMIN_DELETE_STUDENT
    JMP ADMIN_DASHBOARD_LOOP

ADMIN_MERIT_LIST:
    CALL SHOW_MERIT_LIST
    JMP ADMIN_DASHBOARD_LOOP

ADMIN_LOGOUT:
    MOV login_success_flag, 0
    
    CALL CLEAR_SCREEN
    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, logout_msg
    INT 21H
    LEA DX, line
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
ADMIN_DASHBOARD_PROCESS ENDP

DISPLAY_ADMIN_WELCOME PROC
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, admin_dashboard_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    LEA DX, admin_welcome_msg
    INT 21H
    
    RET
DISPLAY_ADMIN_WELCOME ENDP

DISPLAY_ADMIN_MENU PROC
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, admin_option1
    INT 21H
    
    LEA DX, admin_option2
    INT 21H
    
    LEA DX, admin_option3
    INT 21H
    
    LEA DX, admin_option4
    INT 21H
    
    LEA DX, admin_option5
    INT 21H
    
    LEA DX, admin_option6
    INT 21H
    
    LEA DX, line
    INT 21H
    
    RET
DISPLAY_ADMIN_MENU ENDP

GET_ADMIN_CHOICE PROC
    MOV AH, 09H
    LEA DX, admin_choice_prompt
    INT 21H
    
    MOV AH, 01H
    INT 21H
    MOV user_choice, AL
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    RET
GET_ADMIN_CHOICE ENDP

; FEATURE 2: UPDATE MARKS (Admin) 

ADMIN_UPDATE_STUDENT_MARKS PROC
    CALL CLEAR_SCREEN
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, update_marks_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    ; Searching for student
    MOV AH, 09H
    LEA DX, search_id_prompt
    INT 21H
    
    LEA SI, search_id_buffer
    CALL GET_INPUT_STRING
    
    ; Finding student
    CALL FIND_STUDENT_BY_ID
    CMP AX, -1
    JNE STUDENT_FOUND_UPDATE
    
    MOV AH, 09H
    LEA DX, not_found_msg
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    RET
    
STUDENT_FOUND_UPDATE:
    MOV temp_index, AX
    
    MOV AH, 09H
    LEA DX, found_msg
    INT 21H
    
    ; taking    English marks
    MOV AH, 09H
    LEA DX, subject1_name
    INT 21H
    CALL GET_MARKS_INPUT
    
    ; Storing English marks
    MOV SI, temp_index
    MOV AL, temp_marks
    LEA BX, english_marks
    ADD BX, SI
    MOV [BX], AL
    
    ; taking Math marks
    MOV AH, 09H
    LEA DX, subject2_name
    INT 21H
    CALL GET_MARKS_INPUT
    
    ; Storing Math marks
    MOV SI, temp_index
    MOV AL, temp_marks
    LEA BX, math_marks
    ADD BX, SI
    MOV [BX], AL
    
    ; taking Science marks
    MOV AH, 09H
    LEA DX, subject3_name
    INT 21H
    CALL GET_MARKS_INPUT
    
    ; Storing Science marks
    MOV SI, temp_index
    MOV AL, temp_marks
    LEA BX, science_marks
    ADD BX, SI
    MOV [BX], AL
    
    ; Calculating grade
    MOV SI, temp_index
    CALL CALCULATE_GRADE
    
    MOV AH, 09H
    LEA DX, update_success
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
ADMIN_UPDATE_STUDENT_MARKS ENDP

GET_MARKS_INPUT PROC
    PUSH BX
    PUSH CX
    
    XOR BX, BX              
    
READ_DIGIT:
    MOV AH, 01H
    INT 21H                
    
    CMP AL, 0DH            
    JE MARKS_DONE
    
    CMP AL, '0'
    JB READ_DIGIT          
    CMP AL, '9'
    JA READ_DIGIT          
    
    SUB AL, '0'            
    XOR AH, AH            
    
    ; BX = BX * 10 + digit 
    SHL BX, 1               ; BX = BX * 2
    MOV CX, BX              ; CX = BX * 2
    SHL BX, 2               ; BX = BX * 8
    ADD BX, CX              ; BX = BX*8 + BX*2
    ADD BX, AX              ; BX = BX*10 + digit
    
    CMP BX, 100
    JBE READ_DIGIT
    MOV BX, 100            
    JMP READ_DIGIT
    
MARKS_DONE:
    MOV temp_marks, BL     
    
   
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    POP CX
    POP BX
    RET
GET_MARKS_INPUT ENDP

FIND_STUDENT_BY_ID PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV CX, student_count
    CMP CX, 0
    JE NOT_FOUND_FIND
    
    LEA SI, student_ids
    MOV BX, 0
    
FIND_LOOP:
    LEA DI, search_id_buffer
    PUSH BX              ; Saving student index
    PUSH SI
    PUSH DI
    CALL STR_CMP
    POP DI
    POP SI
    POP BX               ; Restoring student index
    CMP AX, 1
    JE FOUND_FIND
    
    ADD SI, STUDENT_ID_LEN
    INC BX
    LOOP FIND_LOOP
    
NOT_FOUND_FIND:
    MOV AX, -1
    JMP FIND_EXIT
    
FOUND_FIND:
    MOV AX, BX
    
FIND_EXIT:
    POP DI
    POP SI
    POP CX
    POP BX
    RET
FIND_STUDENT_BY_ID ENDP

; ==============================================================================
; FEATURE 3: AUTOMATED GRADE CALCULATION
; ==============================================================================
; This procedure calculates average marks and assigns a letter grade.
; ==============================================================================

CALCULATE_GRADE PROC
    ; SI = student index
    ; Formula: Average = (English + Math + Science) / 3
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI                      ; Saving SI to preserve student index
    
    ; Using DI to hold student index for array access
    MOV DI, SI
    
   
    XOR AX, AX
    
    ; Step 1: Adding English marks
    LEA BX, english_marks
    ADD BX, DI
    MOV CL, [BX]
    XOR CH, CH
    ADD AX, CX
    
    ; Step 2: Adding Math marks
    LEA BX, math_marks
    ADD BX, DI
    MOV CL, [BX]
    XOR CH, CH
    ADD AX, CX
    
    ; Step 3: Adding Science marks
    LEA BX, science_marks
    ADD BX, DI
    MOV CL, [BX]
    XOR CH, CH
    ADD AX, CX
    
    ; Saving index in SI for grade storage
    MOV SI, DI
    
    ; Appling weighted logic: Calculate average
    XOR DX, DX                  
    MOV BX, 3                   
    DIV BX                     
    ; Result: AL contains average
    
    ; Storing grade
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '

    CMP AL, 97
    JAE GRADE_A_PLUS

    CMP AL, 93
    JAE GRADE_A

    CMP AL, 90
    JAE GRADE_A_MINUS

    CMP AL, 87
    JAE GRADE_B_PLUS

    CMP AL, 83
    JAE GRADE_B

    CMP AL, 80
    JAE GRADE_B_MINUS

    CMP AL, 77
    JAE GRADE_C_PLUS

    CMP AL, 73
    JAE GRADE_C

    CMP AL, 70
    JAE GRADE_C_MINUS

    CMP AL, 67
    JAE GRADE_D_PLUS

    CMP AL, 60
    JAE GRADE_D

    ; F
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'F'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '
    JMP CALC_DONE

GRADE_A_PLUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'A'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '+'
    JMP CALC_DONE

GRADE_A:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'A'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '
    JMP CALC_DONE

GRADE_A_MINUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'A'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '-'
    JMP CALC_DONE

GRADE_B_PLUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'B'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '+'
    JMP CALC_DONE

GRADE_B:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'B'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '
    JMP CALC_DONE

GRADE_B_MINUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'B'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '-'
    JMP CALC_DONE

GRADE_C_PLUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'C'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '+'
    JMP CALC_DONE

GRADE_C:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'C'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '
    JMP CALC_DONE

GRADE_C_MINUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'C'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '-'
    JMP CALC_DONE

GRADE_D_PLUS:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'D'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], '+'
    JMP CALC_DONE

GRADE_D:
    LEA BX, student_grade
    ADD BX, SI
    MOV BYTE PTR [BX], 'D'
    LEA BX, student_grade_mod
    ADD BX, SI
    MOV BYTE PTR [BX], ' '
    
CALC_DONE:
    POP SI
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CALCULATE_GRADE ENDP

; FEATURE 3: VIEW RESULT 

ADMIN_VIEW_STUDENT_RESULT PROC
    CALL CLEAR_SCREEN
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, result_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    ; Searching for student
    MOV AH, 09H
    LEA DX, search_id_prompt
    INT 21H
    
    LEA SI, search_id_buffer
    CALL GET_INPUT_STRING
    
    ; Finding student
    CALL FIND_STUDENT_BY_ID
    CMP AX, -1
    JNE STUDENT_FOUND_VIEW
    
    MOV AH, 09H
    LEA DX, not_found_msg
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    RET
    
STUDENT_FOUND_VIEW:
    MOV temp_index, AX
    CALL DISPLAY_STUDENT_RESULT
    
    MOV AH, 09H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
ADMIN_VIEW_STUDENT_RESULT ENDP

DISPLAY_STUDENT_RESULT PROC
    PUSH SI                
    PUSH DI                
    PUSH BP                 
    
    ; Saving student index in BP
    MOV BP, temp_index
    
    ; Displaying name and ID
    MOV AX, BP
    MOV BX, STUDENT_NAME_LEN
    XOR DX, DX         
    MUL BX
    LEA SI, student_names
    ADD SI, AX
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    MOV DX, SI
    INT 21H
    LEA DX, newline
    INT 21H
    
   
    MOV SI, BP
    CALL CALCULATE_GRADE
    
    ; Displaying English marks
    MOV AH, 09H
    LEA DX, subject1_name
    INT 21H
    LEA BX, english_marks
    ADD BX, BP
    MOV AL, [BX]
    CALL DISPLAY_NUMBER
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    ; Displaying Math marks
    MOV AH, 09H
    LEA DX, subject2_name
    INT 21H
    LEA BX, math_marks
    ADD BX, BP
    MOV AL, [BX]
    CALL DISPLAY_NUMBER
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    ; Displaying Science marks
    MOV AH, 09H
    LEA DX, subject3_name
    INT 21H
    LEA BX, science_marks
    ADD BX, BP
    MOV AL, [BX]
    CALL DISPLAY_NUMBER
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    ; Displaying average
    MOV AH, 09H
    LEA DX, avg_label
    INT 21H
    
    ; Calculating average
    XOR AX, AX
    XOR CX, CX
    
    LEA BX, english_marks
    ADD BX, BP
    MOV AL, [BX]
    
    LEA BX, math_marks
    ADD BX, BP
    MOV CL, [BX]
    ADD AX, CX
    
    LEA BX, science_marks
    ADD BX, BP
    MOV CL, [BX]
    ADD AX, CX
    
    XOR DX, DX
    MOV CX, 3
    DIV CX
    ; AX = average, AL has result
    CALL DISPLAY_NUMBER
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    ; Displaying Grade
    MOV AH, 09H
    LEA DX, grade_label
    INT 21H
    LEA BX, student_grade
    ADD BX, BP
    MOV DL, [BX]
    MOV AH, 02H
    INT 21H

    ;  + / - modifier
    LEA BX, student_grade_mod
    ADD BX, BP
    MOV AL, [BX]
    CMP AL, ' '
    JE GRADE_PRINT_DONE
    MOV DL, AL
    MOV AH, 02H
    INT 21H

GRADE_PRINT_DONE:
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    POP BP
    POP DI
    POP SI
    RET
DISPLAY_STUDENT_RESULT ENDP

DISPLAY_NUMBER PROC
    ; Displaying number in AL
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR AH, AH              ; AX = number (0-100)
    MOV CL, 100
    DIV CL                  ; AL = hundreds, AH = remainder
    
    MOV CH, AH              ; Saving remainder in CH
    
    CMP AL, 0
    JE SKIP_HUNDREDS
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
SKIP_HUNDREDS:
    MOV AL, CH              ; Restoring remainder
    XOR AH, AH
    MOV CL, 10
    DIV CL                  ; AL = tens, AH = units
    
    MOV CH, AH              ; Saving units in CH
    
    CMP AL, 0
    JE SKIP_TENS
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP PRINT_UNITS
    
SKIP_TENS:
    
    
PRINT_UNITS:
    MOV DL, CH           
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_NUMBER ENDP



; STUDENT DASHBOARD

STUDENT_DASHBOARD_PROCESS PROC
    CALL SAVE_STUDENT_SESSION
    
STUDENT_DASHBOARD_LOOP:
    CALL CLEAR_SCREEN
    CALL DISPLAY_STUDENT_WELCOME
    CALL DISPLAY_STUDENT_MENU
    CALL GET_STUDENT_CHOICE
    
    CMP user_choice, '1'
    JE STUDENT_VIEW_RESULT
    
    CMP user_choice, '2'
    JE STUDENT_ANALYSE_PERFORMANCE
    
    CMP user_choice, '3'
    JE STUDENT_LOGOUT
    
    JMP STUDENT_DASHBOARD_LOOP

STUDENT_VIEW_RESULT:
    CALL STUDENT_SHOW_RESULT
    JMP STUDENT_DASHBOARD_LOOP

STUDENT_ANALYSE_PERFORMANCE:
    CALL STUDENT_PERFORMANCE_ANALYSIS
    JMP STUDENT_DASHBOARD_LOOP

STUDENT_LOGOUT:
    MOV login_success_flag, 0
    
    CALL CLEAR_SCREEN
    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, logout_msg
    INT 21H
    LEA DX, line
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
STUDENT_DASHBOARD_PROCESS ENDP

DISPLAY_STUDENT_WELCOME PROC
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, student_dashboard_title
    INT 21H
    
    LEA DX, line
    INT 21H
    
    LEA DX, student_welcome
    INT 21H
    LEA DX, current_name
    INT 21H
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    MOV AH, 09H
    LEA DX, student_id_label
    INT 21H
    LEA DX, current_id
    INT 21H
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    RET
DISPLAY_STUDENT_WELCOME ENDP

DISPLAY_STUDENT_MENU PROC
    MOV AH, 09H
    LEA DX, line
    INT 21H
    
    LEA DX, dashboard_option1
    INT 21H
    
    LEA DX, dashboard_option2
    INT 21H
    
    LEA DX, dashboard_option3
    INT 21H
    
    LEA DX, line
    INT 21H
    
    RET
DISPLAY_STUDENT_MENU ENDP

GET_STUDENT_CHOICE PROC
    MOV AH, 09H
    LEA DX, dashboard_choice
    INT 21H
    
    MOV AH, 01H
    INT 21H
    MOV user_choice, AL
    
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    RET
GET_STUDENT_CHOICE ENDP

STUDENT_SHOW_RESULT PROC
    CALL CLEAR_SCREEN
    MOV SI, current_student_index
    MOV temp_index, SI
    CALL DISPLAY_STUDENT_RESULT
    
    MOV AH, 09H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
STUDENT_SHOW_RESULT ENDP

; ==============================================================================
; FEATURE 4: STUDENT SUBJECT-WISE PERFORMANCE ANALYSIS
; ==============================================================================
; Allows students to view detailed performance statistics for each subject.
; The system calculates and displays the highest, lowest, and average marks
; for each subject by iterating through the parallel arrays.
; ==============================================================================

STUDENT_PERFORMANCE_ANALYSIS PROC
    CALL CLEAR_SCREEN
    
    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, perf_title
    INT 21H
    LEA DX, line
    INT 21H
    
    MOV CX, student_count
    CMP CX, 0
    JNE PERF_ANALYZE
    
    LEA DX, no_data_msg
    INT 21H
    JMP PERF_END
    
PERF_ANALYZE:
    ; Analyzing English marks
    MOV AH, 09H
    LEA DX, subject1_name
    INT 21H
    LEA BX, english_marks
    CALL ANALYZE_SUBJECT
    
    ; Analyzing Math marks
    MOV AH, 09H
    LEA DX, subject2_name
    INT 21H
    LEA BX, math_marks
    CALL ANALYZE_SUBJECT
    
    ; Analyzing Science marks
    MOV AH, 09H
    LEA DX, subject3_name
    INT 21H
    LEA BX, science_marks
    CALL ANALYZE_SUBJECT
    
PERF_END:
    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    
    RET
STUDENT_PERFORMANCE_ANALYSIS ENDP

ANALYZE_SUBJECT PROC
    
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    MOV CX, student_count       
    MOV SI, 0                 
    
    ; Initializing with first student's mark
    MOV AL, [BX]                 ; Getting first mark from array
    MOV DL, AL                   ; DL = max (initializing with first value)
    MOV DH, AL                   ; DH = min (initializing with first value)
    XOR DI, DI                   ; DI = sum
    
ANALYZE_LOOP:
    ; Getting current student's mark
    MOV AL, [BX + SI]
    
    ; Updating maximum
    CMP AL, DL                   
    JBE CHECK_MIN_A             
    MOV DL, AL                  
    
CHECK_MIN_A:
    ; Updating minimum 
    CMP AL, DH                  
    JAE ADD_SUM_A              
    MOV DH, AL                  
    
ADD_SUM_A:
    ; Adding current mark to sum
    XOR AH, AH                  
    ADD DI, AX                  
    
    INC SI                      
    LOOP ANALYZE_LOOP           
    
   
    MOV CH, DL                   ; CH = max
    MOV CL, DH                   ; CL = min
    
    ; Calculating average by dividing sum by student count
    MOV AX, DI                  
    MOV BX, student_count        
    XOR DX, DX                  
    DIV BX                      
    ; Result: AL contains average mark
    
    ; Now: CH = max, CL = min, AL = average
    PUSH AX                   
    
    ; Displaying highest mark
    MOV AH, 09H
    LEA DX, highest_label
    INT 21H
    MOV AL, CH                  
    CALL DISPLAY_NUMBER
    
    ; Displaying separator
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    
    ; Displaying lowest mark
    MOV AH, 09H
    LEA DX, lowest_label
    INT 21H
    MOV AL, CL                  
    CALL DISPLAY_NUMBER
    
    ; Displaying separator
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    
    ; Displaying average mark
    MOV AH, 09H
    LEA DX, average_label
    INT 21H
    POP AX                     
    CALL DISPLAY_NUMBER
    
    ; Print newline
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
ANALYZE_SUBJECT ENDP 





; ===================================================
; Feature 5: Delete Student
; Main procedure to delete a student by ID
; ===================================================
ADMIN_DELETE_STUDENT PROC
    CALL CLEAR_SCREEN

    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, newline
    INT 21H
    LEA DX, search_id_prompt
    INT 21H

    ; Getting ID to delete
    LEA SI, search_id_buffer
    CALL GET_INPUT_STRING

    ; Searching for student
    CALL FIND_STUDENT_BY_ID
    CMP AX, -1
    JNE STUDENT_FOUND_DELETE

    ; Student not found
    MOV AH, 09H
    LEA DX, not_found_msg
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H
    RET

STUDENT_FOUND_DELETE:
    MOV temp_index, AX            

    ; Confirm deletion
    MOV AH, 09H
    LEA DX, delete_confirm
    INT 21H

    MOV AH, 01H
    INT 21H
    CMP AL, 'Y'
    JE DO_DELETE
    CMP AL, 'y'
    JE DO_DELETE
    JMP DELETE_CANCEL

DO_DELETE:
    CALL DELETE_STUDENT_BY_INDEX   

    MOV AH, 09H
    LEA DX, delete_success
    INT 21H
    JMP DELETE_END

DELETE_CANCEL:
    MOV AH, 09H
    LEA DX, newline
    INT 21H

DELETE_END:
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H

    RET
ADMIN_DELETE_STUDENT ENDP


; ===================================================
; DELETE_STUDENT_BY_INDEX
; Deletes student at temp_index by shifting all subsequent records
; ===================================================
DELETE_STUDENT_BY_INDEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP
    PUSH SI
    PUSH DI
    PUSH ES

    PUSH DS
    POP ES                          
    CLD                             

    MOV BX, temp_index             
    MOV AX, student_count
    DEC AX
    MOV BP, AX                      

SHIFT_RECORDS:
    CMP BX, BP
    JAE DELETE_DONE                

    ; --- Shifting Name ---
    MOV AX, BX
    MOV CX, STUDENT_NAME_LEN
    MUL CX
    LEA DI, student_names
    ADD DI, AX                     

    MOV AX, BX
    INC AX
    MOV CX, STUDENT_NAME_LEN
    MUL CX
    LEA SI, student_names
    ADD SI, AX                     
    MOV CX, STUDENT_NAME_LEN
    REP MOVSB

    ; --- Shifting ID ---
    MOV AX, BX
    MOV CX, STUDENT_ID_LEN
    MUL CX
    LEA DI, student_ids
    ADD DI, AX

    MOV AX, BX
    INC AX
    MOV CX, STUDENT_ID_LEN
    MUL CX
    LEA SI, student_ids
    ADD SI, AX
    MOV CX, STUDENT_ID_LEN
    REP MOVSB

    ; --- Shifting Password ---
    MOV AX, BX
    MOV CX, STUDENT_PASS_LEN
    MUL CX
    LEA DI, student_passwords
    ADD DI, AX

    MOV AX, BX
    INC AX
    MOV CX, STUDENT_PASS_LEN
    MUL CX
    LEA SI, student_passwords
    ADD SI, AX
    MOV CX, STUDENT_PASS_LEN
    REP MOVSB

    ; --- Shifting marks and grades
    MOV SI, BX
    INC SI                         

    ; English
    LEA DI, english_marks
    ADD DI, SI
    MOV AL, [DI]
    LEA DI, english_marks
    ADD DI, BX
    MOV [DI], AL

    ; Math
    LEA DI, math_marks
    ADD DI, SI
    MOV AL, [DI]
    LEA DI, math_marks
    ADD DI, BX
    MOV [DI], AL

    ; Science
    LEA DI, science_marks
    ADD DI, SI
    MOV AL, [DI]
    LEA DI, science_marks
    ADD DI, BX
    MOV [DI], AL

    ; Grade letter
    LEA DI, student_grade
    ADD DI, SI
    MOV AL, [DI]
    LEA DI, student_grade
    ADD DI, BX
    MOV [DI], AL

    ; Grade modifier
    LEA DI, student_grade_mod
    ADD DI, SI
    MOV AL, [DI]
    LEA DI, student_grade_mod
    ADD DI, BX
    MOV [DI], AL

    INC BX                         
    JMP SHIFT_RECORDS

DELETE_DONE:
    DEC student_count              

    POP ES
    POP DI
    POP SI
    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DELETE_STUDENT_BY_INDEX ENDP


; ===================================================
; Feature 6: Show Merit List
; Displays ranked merit list based on average marks
; ===================================================
SHOW_MERIT_LIST PROC
    CALL CLEAR_SCREEN

    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, merit_title
    INT 21H
    LEA DX, line
    INT 21H

    MOV CX, student_count
    CMP CX, 0
    JNE PREPARE_MERIT_DATA

    MOV AH, 09H
    LEA DX, no_data_msg
    INT 21H
    JMP MERIT_LIST_END

PREPARE_MERIT_DATA:
    CALL CALCULATE_ALL_AVERAGES     ; Computing average for each student
    CALL CREATE_SORTED_LIST         ; Sorting students by average (descending)

    CALL DISPLAY_MERIT_TABLE        ; Printing formatted table

MERIT_LIST_END:
    MOV AH, 09H
    LEA DX, line
    INT 21H
    LEA DX, press_key_msg
    INT 21H
    MOV AH, 01H
    INT 21H

    RET
SHOW_MERIT_LIST ENDP


; ===================================================
; CALCULATE_ALL_AVERAGES
; Computing average for each student and stores in student_averages[]
; ===================================================
CALCULATE_ALL_AVERAGES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, student_count
    CMP CX, 0
    JE CALC_AVG_DONE

    MOV SI, 0                       ; Current student index

CALC_AVG_LOOP:
    XOR AX, AX                     

    ; English
    LEA BX, english_marks
    ADD BX, SI
    MOV AL, [BX]
    XOR AH, AH

    ; Math
    LEA BX, math_marks
    ADD BX, SI
    MOV DL, [BX]
    ADD AX, DX

    ; Science
    LEA BX, science_marks
    ADD BX, SI
    MOV DL, [BX]
    ADD AX, DX                      ; AX = total marks

    MOV DX, 0
    MOV BX, 3
    DIV BX                          ; AL = average

    ; Store average
    LEA BX, student_averages
    ADD BX, SI
    MOV [BX], AL

    INC SI
    LOOP CALC_AVG_LOOP

CALC_AVG_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CALCULATE_ALL_AVERAGES ENDP


; ===================================================
; CREATE_SORTED_LIST
; Builds sorted_list[] containing student indices sorted by average (descending)
; Uses bubble sort on indices
; ===================================================
CREATE_SORTED_LIST PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH BP

    MOV CX, student_count
    CMP CX, 0
    JE SORT_COMPLETE
    CMP CX, 1
    JE INIT_ONLY

    ; Initializing sorted_list with 0, 1, 2, ..., n-1
INIT_ONLY:
    MOV SI, 0
    LEA BX, sorted_list
INIT_LOOP:
    MOV [BX], SI
    ADD BX, 2
    INC SI
    CMP SI, student_count
    JL INIT_LOOP

    ; Bubble sort (descending by average)
    MOV CX, student_count
    DEC CX

OUTER_LOOP:
    PUSH CX
    LEA SI, sorted_list
    MOV DX, 0                      

    MOV CX, student_count
    DEC CX

INNER_LOOP:
    MOV DI, [SI]                    ; First index
    MOV BX, [SI+2]                  ; Second index

    ; Comparing averages
    PUSH SI
    LEA SI, student_averages
    ADD SI, DI
    MOV AL, [SI]                    ; Average of first

    LEA SI, student_averages
    ADD SI, BX
    MOV AH, [SI]                    ; Average of second
    POP SI

    CMP AL, AH
    JAE NO_SWAP                     ; Already in order (descending)

    ; Swapping indices
    MOV [SI], BX
    MOV [SI+2], DI
    MOV DX, 1

NO_SWAP:
    ADD SI, 2
    LOOP INNER_LOOP

    POP CX
    CMP DX, 0
    JE SORT_COMPLETE                ;  sorted
    LOOP OUTER_LOOP

SORT_COMPLETE:
    POP BP
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CREATE_SORTED_LIST ENDP


; ===================================================
; DISPLAY_MERIT_TABLE
; Prints formatted merit list: Rank | Name | Average | Grade
; ===================================================
DISPLAY_MERIT_TABLE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV AH, 09H
    LEA DX, merit_header_line
    INT 21H
    LEA DX, merit_divider
    INT 21H

    MOV CX, student_count
    CMP CX, 0
    JE NO_STUDENTS_DISPLAY

    MOV SI, 0                       ; Rank counter

DISPLAY_LOOP:
    PUSH CX

    ; Getting actual student index from sorted list
    MOV DI, SI
    SHL DI, 1                      
    LEA BX, sorted_list
    MOV DI, [BX+DI]

    ; Printing rank 
    MOV AX, SI
    INC AX
    CALL PRINT_RANK

    ; name
    MOV AX, DI
    MOV BX, STUDENT_NAME_LEN
    MUL BX
    LEA DX, student_names
    ADD DX, AX
    MOV AH, 09H
    INT 21H

   
    PUSH DI
    CALL ADD_PADDING
    POP DI

    ; average
    LEA BX, student_averages
    ADD BX, DI
    MOV AL, [BX]
    CALL DISPLAY_NUMBER

    ; Spacing
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    INT 21H
    INT 21H
    INT 21H

    ; Print grade letter
    LEA BX, student_grade
    ADD BX, DI
    MOV DL, [BX]
    INT 21H

    ; Printing + or - 
    LEA BX, student_grade_mod
    ADD BX, DI
    MOV AL, [BX]
    CMP AL, ' '
    JE NO_GRADE_MOD
    MOV DL, AL
    MOV AH, 02H
    INT 21H

NO_GRADE_MOD:
    ; New line
    MOV AH, 02H
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H

    POP CX
    INC SI
    LOOP DISPLAY_LOOP

    JMP DISPLAY_FINISHED

NO_STUDENTS_DISPLAY:
    MOV AH, 09H
    LEA DX, no_data_msg
    INT 21H

DISPLAY_FINISHED:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_MERIT_TABLE ENDP


; ===================================================
; PRINT_RANK
; Prints rank number with proper formatting 
; ===================================================
PRINT_RANK PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 10
    JB ONE_DIGIT_RANK

    
    MOV BX, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX

    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    INT 21H

    MOV DL, '.'
    INT 21H
    MOV DL, ' '
    INT 21H
    JMP RANK_DONE

ONE_DIGIT_RANK:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    MOV DL, '.'
    INT 21H
    MOV DL, ' '
    INT 21H
    INT 21H
    INT 21H
    INT 21H

RANK_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_RANK ENDP


; ===================================================
; ADD_PADDING
; Adds spaces to align name column (up to 25 characters)
; ===================================================
ADD_PADDING PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV BX, DX                     
    MOV SI, BX
    MOV CX, 0                       

COUNT_CHARACTERS:
    CMP BYTE PTR [SI], '$'
    JE DONE_COUNT
    INC SI
    INC CX
    JMP COUNT_CHARACTERS

DONE_COUNT:
    MOV AX, 25
    SUB AX, CX                    
    JBE NO_PADDING

    MOV CX, AX
    MOV AH, 02H
PRINT_SPACES:
    MOV DL, ' '
    INT 21H
    LOOP PRINT_SPACES

NO_PADDING:
    MOV DX, BX                    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ADD_PADDING ENDP

END MAIN