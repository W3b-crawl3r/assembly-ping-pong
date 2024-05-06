stack segment para 'stack'
   db 64 DUP (' ')
stack ends

data segment para 'data'

    ball_x dw 0ah ; x axis of the ball
    ball_y dw 0ah ; y axis of the ball
    ball_size dw 04h ;size of the ball
    time_old db 0 ; the previous time 
    ball_original_x dw 0a0h
    ball_original_y dw 64h
    
    ball_vel_x dw 05h ;velocity in the x axis (hori)
    ball_vel_y dw 02h ;velocity in the y axis(verti)
    window_width dw 140h;320px
    window_height dw 0c8h;200px
    window_boundry dw 6 ;limitr to window boundries
    paddle_x dw 0ah
    paddle_y dw 0ah
    paddle_width dw 05H
    paddle_height dw 1fh
    paddle_velocity dw 05h
    
data ends

code segment para 'code'

    main proc far
    assume cs:code,ds:data,ss:stack 
    push ds ; push to stack ds segmnt
    sub ax,ax ; make ax null
    push ax ; push ax to stack
    mov ax,data
    mov ds,ax
    pop ax
    pop ax
    
        call cls
        
    see_time: 
        mov ah,2ch ; to get system time
        int 21h
        
        cmp dl,time_old
        je see_time
        mov time_old,dl ;update time
        
        call cls
        
        call movb
        
        call draw_ball
        
        call movp
        
        call draw_paddle
        
        jmp see_time
        
        ret
    main endp
    
    draw_ball proc near
        
        mov cx,ball_x ;set column (x)
        mov dx,ball_y ;set line (y)
    dbh:
        mov ah,0ch ;set config to writ px
        mov al,0fh ;color of px , white
        mov bh,00h ;page number 00
        int 10h ;execute
        
        inc cx ;add 1 to cx (aka next line)
        mov ax,cx
        sub ax,ball_x
        cmp ax,ball_size ;testing if we reached the end of ball
        jng dbh
        
        mov cx,ball_x ;back to the first colum to start the next line
        inc dx
        
        mov ax,dx
        sub ax,ball_y
        cmp ax,ball_size
        jng dbh 
    
        ret
      draw_ball endp
      
      movb proc near
        
        mov ax,ball_vel_x
        add ball_x,ax
        mov ax,window_boundry
        cmp ball_x,ax
        jl reset_pos ;reset ball place if it goes thru left side
        
        mov ax,window_width
        sub ax,ball_size
        sub ax, window_boundry
        cmp ball_x,ax ;test if it colided with right wall
        jg nvelo_x
        
        mov ax, ball_vel_y
        add ball_y,ax
        
        mov ax,window_boundry
        cmp ball_y,ax ;test if it colided with top/bottom
        jl nvelo_y
        mov ax,window_height
        sub ax,ball_size
        sub ax, window_boundry
        cmp ball_y,ax
        jg nvelo_y
        
         mov ax,ball_x   ;check colliding
         add ax,ball_size
         cmp ax,paddle_x
         jng exit_coll
         
         mov ax,paddle_x
         add ax,paddle_width
         cmp ball_x,ax
         jnl exit_coll
         
         mov ax,ball_y
         add ax,ball_size
         cmp ax,paddle_y
         jng exit_coll
         
         mov ax,paddle_y
         add ax,paddle_height
         cmp ball_y,ax
         jnl exit_coll
         
         neg ball_vel_x ;revers becouse it colidded
        
        ret
        
    exit_coll:
        ret
        
    reset_pos:
        call reset_ball
        ret
        
    nvelo_x:
        neg ball_vel_x ;revers valiu to collide right side
        ret
    nvelo_y:
        neg ball_vel_y ;reves valiu to collide top/botom
        ret
        
      movb endp
      
      movp proc near
        
        mov ah,01h
        int 16h ;to see if a key is being pressed
        jz exit_paddle
        
        mov ah,00h
        int 16h
        
        cmp al,77h ;to test if w is pressed
        je move_paddle_up
        cmp al,57h ;to test if W is pressed
        je move_paddle_up
        
         cmp al,73h ;to test if s is pressed
         je move_paddle_down
         cmp al,53h ;to test if S is pressed
        je move_paddle_down
        jmp exit_paddle
        
    move_paddle_up:
        mov ax,paddle_velocity
        sub paddle_y,ax
        
        mov ax,window_boundry
        cmp paddle_y,ax
        jl fix_paddle_top
        jmp exit_paddle
        
    fix_paddle_top:
        mov ax,window_boundry
        mov paddle_y,ax
        
    move_paddle_down:
        mov ax,paddle_velocity
        add paddle_y,ax
        mov ax,window_height
        sub ax,window_boundry
        sub ax,paddle_height
        cmp paddle_y,ax
        jg fix_paddle_bottom
        jmp exit_paddle
        
    fix_paddle_bottom:
        mov paddle_y,ax
        jmp exit_paddle
        
    exit_paddle:
        
        ret
      movp endp
      
      reset_ball proc near
        
        mov ax,ball_original_x
        mov ball_x,ax
        mov ax,ball_original_y
        mov ball_y,ax
        ret
      reset_ball endp
      
      draw_paddle proc near
        
        mov cx,paddle_x
        mov dx,paddle_y
    draw_paddle_hori:
        
        mov ah,0ch ;set config to writ px
        mov al,0fh ;color of px , white
        mov bh,00h ;page number 00
        int 10h ;execute
        
        inc cx ;add 1 to cx (aka next line)
        mov ax,cx
        sub ax,paddle_x
        cmp ax,paddle_width ;testing if we reached the end of paddel
        jng draw_paddle_hori
        
        mov cx,paddle_x ;back to the first colum to start the next line
        inc dx
        
        mov ax,dx
        sub ax,paddle_y
        cmp ax,paddle_height
        jng draw_paddle_hori 
        
        ret
      draw_paddle endp
        
      cls proc near
        mov ah,00h ; set config vedio mode
        mov al,13h ; choose vid mode
        int 10h ;execute
        
        mov ah,0bh ; set config
        mov bh,00h ;bg color
        mov bl,00h ;black color code 
        int 10h ; execute
        ret
      cls endp
    
code ends
end