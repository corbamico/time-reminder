; 

    include \masm64\include64\masm64rt.inc

    COLOR_GREEN equ <00008000h>                           ; window & control back colour
    COLOR_RED   equ <000000FFh>                           ; window & control back colour

    .data?
      hInstance dq ?
      hWnd      dq ?
      hIcon     dq ?
      hCursor   dq ?
      sWid      dq ?
      sHgt      dq ?
      hBrushGreen    dq ?
      hBrushRed      dq ?
      hStat     dq ?
      hFont     dq ?

      pCmd      dq ?
      tcnt      dq ?                    ; start tick count
      cntt      dq ?                    ; duration tick count

      cnt       dq ?
      hTimer    dq ?

    .data
      classname db "reminder_class",0
      caption   db "Reminder",0
      TimerID   dq 0

      var       dq 0
      mcnt      dq 0
      timer_minutes     dq 1                   ;default timer 1 minutes
      timer_ticks       dq 60000

    .code

; 
MINMAXINFO STRUCT 
  ptReserved POINT<>
  ptMaxSize  POINT<>
  ptMaxPosition POINT<>
  ptMinTrackSize POINT<>
  ptMaxTrackSize POINT<>
MINMAXINFO ENDS


WinMainCRTStartup proc

    GdiPlusBegin                    ; initialise GDIPlus

    ics equ <64>                    ; icon size


    ;accept one argv, for minutes ticking
    mov rcx, rvcall(cmd_tail)
    ; mov rcx, pCmd
    ; argument in RCX
    ; return value in EAX
    ; non zero in RCX for success
    call atou_ex
    .if rcx ~= 0 && rax ~=0 && rax {= 300
      mov timer_minutes, rax
      imul rax, 60000
      mov timer_ticks, rax
    .endif

    mov hInstance, rvcall(GetModuleHandle,0)
    mov hIcon,     rv(LoadImage,hInstance,10,IMAGE_ICON,ics,ics,LR_DEFAULTCOLOR)
    mov hCursor,   rvcall(LoadCursor,0,IDC_ARROW)
    mov sWid,      rvcall(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,      rvcall(GetSystemMetrics,SM_CYSCREEN)
    mov hBrushGreen,    rvcall(CreateSolidBrush,COLOR_GREEN)
    mov hBrushRed,      rvcall(CreateSolidBrush,COLOR_RED)
    
    mov hFont,     GetFontHandle("Segoe UI",20,600)

    call main

    GdiPlusEnd                      ; GdiPlus cleanup

    .exit
    ret
WinMainCRTStartup endp

; 

main proc

    LOCAL wc      :WNDCLASSEX
    LOCAL lft     :QWORD
    LOCAL top     :QWORD
    LOCAL wid     :QWORD
    LOCAL hgt     :QWORD

    mov wc.cbSize,         SIZEOF WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,    ptr$(WndProc)
    mov wc.cbClsExtra,     0
    mov wc.cbWndExtra,     0
    mrm wc.hInstance,      hInstance
    mrm wc.hIcon,          hIcon
    mrm wc.hCursor,        hCursor
    mrm wc.hbrBackground,  hBrushGreen
    mov wc.lpszMenuName,   0
    mov wc.lpszClassName,  ptr$(classname)
    mrm wc.hIconSm,        hIcon

    rcall RegisterClassEx,ptr$(wc)

    mov wid, 142
    mov hgt, 42

    mov rax, sWid                           ; calculate offset from left side
    sub rax, wid
    shr rax, 1
    mov lft, rax

    mov rax, sHgt                           ; calculate offset from top edge
    sub rax, hgt
    shr rax, 1
    mov top, rax

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_TOPMOST, \
                          ADDR classname,ADDR caption, \
                          WS_POPUP or WS_VISIBLE ,\     ;  or WS_SYSMENU
                          lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd, rax

    call msgloop

    ret

main endp

; 

msgloop proc

    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD

    mov pmsg, ptr$(msg)                     ; get the msg structure address
    jmp gmsg                                ; jump directly to GetMessage()

  mloop:
    rcall TranslateMessage,pmsg
    rcall DispatchMessage,pmsg
  gmsg:
    test rax, rvcall(GetMessage,pmsg,0,0,0) ; loop until GetMessage returns zero
    jnz mloop

    ret

msgloop endp

; 

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    LOCAL pbuf  :QWORD
    LOCAL buff[128]:BYTE

    LOCAL seconds :QWORD

    LOCAL left_minutes :QWORD
    LOCAL left_seconds :QWORD

    .switch uMsg
      .case WM_CREATE
        mrm hWnd, hWin
        mov hStat, rv(static_control,0,0,142,42,0)
        rcall SendMessage,hStat,WM_SETFONT,hFont,TRUE

        mov tcnt, rvcall(GetTickCount)
        mov hTimer, rvcall(SetTimer,hWin,TimerID,990,0)    ;every 1s timer
        .return 0

      .case WM_CTLCOLORSTATIC                                       ; static colour control
        rcall SetTextColor,wParam,00EEEEEEh
        mov rax, timer_minutes
        .if mcnt { rax
          rcall SetBkColor,wParam,COLOR_GREEN          
          mov rax, hBrushGreen
        .else
          rcall SetBkColor,wParam,COLOR_RED
          mov rax, hBrushRed
        .endif
        ret

      .case WM_NCHITTEST
        rcall DefWindowProc,hWin,uMsg,wParam,lParam
        .if rax == HTCLIENT
            mov rax, HTCAPTION
        .endif
        ret

      .case WM_TIMER
      ; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        ; tcnt ： tick-count  at app start point
        ; cntt ： count tick  from app start

        ; mcnt ： minutes-count  every minute timer
        ; cnt  ： second-count   every minute timer

        ; seconds = cntt/1000  -  cnt 
      ; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        rcall GetTickCount
        sub rax, tcnt
        mov cntt, rax                                               ; current tick count from app start

        add var,1
        .if var } 60
          add mcnt, 1
          add cnt, 60                                               ; cnt used by following second calculation
          mov var, 0        
        .endif

        mov r10, cntt
        invoke intdiv,r10,1000
        sub rax, cnt
        mov seconds,rax

        mov pbuf, ptr$(buff)
        mov rax, timer_minutes
        .if mcnt { rax
          mov rax, timer_minutes
          sub rax, mcnt
          sub rax, 1
          mov left_minutes,rax
          mov rax, 60
          sub rax, seconds
          mov left_seconds,rax

          mcat pbuf,"left  ",str$(left_minutes), ":", str$(left_seconds)  ,"s"
          ;mcat pbuf,pLeft,str$(left_minutes), ":", str$(left_seconds)  ,"s"
        .else
          mov rax, mcnt
          sub rax, timer_minutes
          mov left_minutes,rax
          mcat pbuf,"timeout ",str$(left_minutes), ":", str$(seconds)  ,"s"
        .endif

        rcall SetWindowText,hStat,pbuf

      .case WM_GETMINMAXINFO
        mov rax, lParam
        mov [rax](MINMAXINFO.ptMaxSize.x), 142
        mov [rax](MINMAXINFO.ptMaxSize.y),  42
        .return 0

      .case WM_CLOSE
        rcall KillTimer,hWin,TimerID
        rcall SendMessage,hWin,WM_DESTROY,0,0

      .case WM_DESTROY
        rcall PostQuitMessage,NULL
    .endsw

    rcall DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; 
static_control proc tx:QWORD,ty:QWORD,wd:QWORD,ht:QWORD,bdr:QWORD

    LOCAL sStyle :QWORD

    mov sStyle, WS_CHILD or WS_VISIBLE or SS_CENTER or SS_CENTERIMAGE ;SS_LEFT

    .if bdr == 1
      or sStyle, WS_BORDER
    .endif

    invoke CreateWindowEx,WS_EX_LEFT,"STATIC",0,sStyle,tx,ty,wd,ht,hWnd,0,hInstance,0

    ret

static_control endp

; 
    end
