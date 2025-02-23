#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

;方向キー
vk1D & j::
    if getkeystate("shift","P"){
        send +{left}
    }else{
        Send, {left}
    }
return

vk1D & l::
    if getkeystate("shift","P"){
        send +{right}
    }else{
        Send, {right}
    }
return

vk1D & i::
    if getkeystate("shift","P"){
        send +{up}
    }else{
        Send, {up}
    }
return

vk1D & k::
    if getkeystate("shift","P"){
        send +{down}
    }else{
        Send, {down}
    }
return


;実行
vk1D & h::send,{f5}

;全体選択
vk1D & a::send,^{a}

;エスケープキー
vk1D & e::send,{Esc}

;保存
vk1D & s::send,^{s}

;エンター
vk1D & m::
    if getkeystate("control","P"){
        send ^{Enter}
    }else{
        send, {Enter}
    }
return


;削除
vk1D & p::Send, {backspace}

;コピペ
vk1D & n::Send, ^{c}
vk1D & ,::Send, ^{v}

;操作を戻す、やり直し
vk1D & u::
    if getkeystate("shift","P"){
        Send, {'}
    }else{
        Send, ^{z}
    }
return



vk1D & y::Send, ^{y}


;半角全角切り替え
vk1D & o::Send,{vkF3sc029}


;テンキー
capslock & '::send,{7}
capslock & (::send,{8}
capslock & )::send,{9}
capslock & u::send,{4}
capslock & i::send,{5}
capslock & o::send,{6}
capslock & j::send,{1}
capslock & k::send,{2}
capslock & l::send,{3}
capslock & m::send,{0}

;shift大文字
vk1C::shift

;&を入力
~vk1C & t::
    if getkeystate("shift","P"){
        Send, {&}
    }else{
        Send, {T}
    }
return
