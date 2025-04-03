;==========================================
; Template Code for 8051 (A51 Assembly)
;==========================================
; Chức năng:
; - Xử lý nút nhấn (2 nút)
; - Hiển thị trên OLED SSD1306 I2C
; - Đọc giá trị từ cảm biến (8 chân input 0/1)
;
;==========================================

ORG 0000H      ; Bắt đầu từ địa chỉ 0

;===============
; KHAI BÁO THANH GHI VÀ CHÂN SỬ DỤNG
;===============
; BẢNG CHỨC NĂNG CỦA CHÂN
;------------------------------------------
; Tên      	| Chân 8051  	| Chức năng
;------------------------------------------
; BTN1    	| P3.0      	| Nút nhấn 1
; BTN2     	| P3.1      	| Nút nhấn 2
; SDA      	| P2.0      	| Dữ liệu I2C
; SCL      	| P2.1      	| Xung I2C
; SENSOR   	| P1        	| 8-bit input cảm biến
;
; BẢNG THANH GHI
;------------------------------------------
; Tên        		| Địa chỉ  | Chức năng
;------------------------------------------
; P1         		| 90H       | Cổng vào cảm biến (8-bit)
; P2         		| A0H       | I2C cho OLED SSD1306
; P3         		| B0H       | Cổng vào cho nút nhấn
; BTN1_STATE 	    | 30H       | Lưu trạng thái nút 1
; BTN2_STATE	    | 31H       | Lưu trạng thái nút 2  
; SENSOR_VAL 	    | 32H       | Lưu giá trị cảm biến (8-bit)
;

;=============== 
; KHAI BÁO BIẾN TRONG RAM
;=============== 
ORG 30H  ; Đặt địa chỉ bắt đầu cho biến trong RAM
BTN1_STATE: DS 1  ; 1 byte lưu trạng thái nút 1
BTN2_STATE: DS 1  ; 1 byte lưu trạng thái nút 2
SENSOR_VAL: DS 1  ; 1 byte lưu giá trị cảm biến



BTN1    EQU P3.0  ; Nút nhấn 1
BTN2    EQU P3.1  ; Nút nhấn 2
SDA     EQU P2.0  ; Dữ liệu I2C
SCL     EQU P2.1  ; Xung I2C
SENSOR  EQU P1    ; Cảm biến (8 input)

;===============
; KHỞI TẠO HỆ THỐNG
;===============
START:
    MOV P1, #0FFH        ; Cấu hình cổng P1 là input
    MOV P3, #0FFH        ; Kéo lên nội trở cho nút nhấn
    MOV 30H, #00H  ; BTN1_STATE
    MOV 31H, #00H  ; BTN2_STATE
   MOV 32H, #00H  ; SENSOR_VAL
    CALL OLED_INIT       ; Khởi tạo OLED

MAIN_LOOP:
    CALL CHECK_BUTTONS  ; Kiểm tra nút nhấn
    CALL READ_SENSOR    ; Đọc giá trị từ cảm biến
    CALL DISPLAY_OLED   ; Cập nhật OLED
    SJMP MAIN_LOOP      ; Lặp vô hạn

;===============
; XỬ LÝ NÚT NHẤN
;===============
CHECK_BUTTONS:
    MOV A, P3         ; Đọc giá trị từ cổng nút nhấn
    MOV 30H, A ; Lưu trạng thái nút 1
    MOV 31H, A ; Lưu trạng thái nút 2
    RET

;===============
; ĐỌC GIÁ TRỊ CẢM BIẾN
;===============
READ_SENSOR:
    MOV A, P1        ; Đọc giá trị từ cảm biến
    MOV 32H, A ; Lưu giá trị vào thanh ghi
    RET

;===============
; HIỂN THỊ DỮ LIỆU LÊN OLED
;===============
DISPLAY_OLED:
    ; Code hiển thị lên OLED SSD1306 tại đây
    RET

;===============
; KHỞI TẠO OLED SSD1306
;===============
OLED_INIT:
    ; Code khởi tạo OLED tại đây
    RET

END
