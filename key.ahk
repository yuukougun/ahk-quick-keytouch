#SingleInstance, Force
#InstallKeybdHook
SendMode Input
SetWorkingDir, %A_ScriptDir%

;方向キー
; vk1D & j::send leftじゃなくてvk1D & j::leftにしたらifいらんかも
vk1D & j::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{left}
    }else if getkeystate("shift", "P"){
        send +{left}
    }else if getkeystate("ctrl", "P"){
        send ^{left}
    }else{
        send, {left}
    }
return

vk1D & l::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{right}
    }else if getkeystate("shift", "P"){
        send +{right}
    }else if getkeystate("ctrl", "P"){
        send ^{right}
    }else{
        send, {right}
    }
return

!i::send !{up}
!+i::send !+{up}
!^i::send !^{up}

vk1D & i::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{up}
    }else if getkeystate("shift", "P"){
        send +{up}
    }else if getkeystate("ctrl", "P"){
        send ^{up}
    }else{
        send, {up}
    }
return

!k::send !{down}
!+k::send !+{down}
!^k::send !^{down}

vk1D & k::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{down}
    }else if getkeystate("shift", "P"){
        send +{down}
    }else if getkeystate("ctrl", "P"){
        send ^{down}
    }else{
        send, {down}
    }
return

;デスクトップ切り替え(Lshift + RShift + a,dで切り替えに変更)
#If (getkeystate("LShift", "P") and getkeystate("RShift", "P"))
    *a::send {Shift Up}#^{left}
    *d::send {Shift Up}#^{right}
#If

;実行
vk1D & h::send, {f5}

;全体選択
vk1D & a::send ^{a}

;エスケープキー
vk1D & e::send, {Esc}

;保存
vk1D & s::send ^{s}

;エンター
vk1D & m::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{enter}
    }else if getkeystate("shift", "P"){
        send +{enter}
    }else if getkeystate("ctrl", "P"){
        send ^{enter}
    }else{
        send, {enter}
    }
return


;削除
vk1D & p::send, {backspace}

;コピペ
vk1D & n::send ^{c}
vk1D & x::send ^{x}
vk1D & ,::send ^{v}

;操作を戻す、やり直し
vk1D & u::
    if getkeystate("shift","P"){
        send, {'}
    }else{
        send ^{z}
    }
return

vk1D & y::send ^{y}


;半角全角切り替え
vk1D & o::send, {vkF3sc029}


;テンキー
F13::Return

vkF0::
    if(getkeystate("F13")){
        send, {Blind}{F13 Up}
    }else{
        send, {Blind}{F13 Down}
    }
return

#If GetKeyState("F13")
    $7::send, {Asc 55} ;7
    $8::send, {Asc 56} ;8
    $+8::send, {Asc 40} ;(
    $9::send, {Asc 57} ;9
    $+9::send, {Asc 41} ;)
    u::send, {Asc 52} ;4
    i::send, {Asc 53} ;5
    o::send, {Asc 54} ;6
    j::send, {Asc 49} ;1
    k::send, {Asc 50} ;2
    l::send, {Asc 51} ;3
    m::send, {Asc 48} ;0
    $0::send, {Asc 48} ;0
    $,::send, {Asc 44} ;,
    $+,::send, {Asc 60} ;<
    $-::send, {Asc 45} ;-
    $+-::send, {Asc 61} ;=
    $.::send, {Asc 46} ;.
    $+.::send, {Asc 62} ;>
    $/::send, {Asc 47} ;/
    $^::send, {Asc 94} ;^
    $+^::send, {Asc 126} ;~
    VKBA::send, {Asc 42} ;*
    VKBB::send, {Asc 43} ;+
    $VKDB::send, {Asc 91} ;[
    $VKDD::send, {Asc 93} ;]
    p::send, {backspace}

    a::left
    d::right
    w::up
    s::down
#If

;特殊操作
vk1D & .::send,{PgUp}
vk1D & /::send,{PgDn}

vk1D & VKBB::
    if getkeystate("shift", "P"){
        send, +{Home}
    }else{
        send, {Home}
    }
return

vk1D & VKBA::
    if getkeystate("shift", "P"){
        send, +{End}
    }else{
        send, {End}
    }
return

vk1D & @::send,{Insert}
vk1D & [::send,{Delete}

;shift大文字
vk1C::shift

;&を入力
~vk1C & t::
    if getkeystate("shift","P"){
        send, {&}
    }else{
        send, {T}
    }
return
