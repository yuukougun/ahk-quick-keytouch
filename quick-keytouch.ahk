#SingleInstance, Force
#InstallKeybdHook
#MaxHotkeysPerInterval 200
SendMode Input
SetWorkingDir, %A_ScriptDir%

CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

numpadMode := false
funcMenuOpen := false

;機能メニュー（無変換 + CapsLock）
Menu, FuncMenu, Add, &a メモ帳, OpenNotepad
Menu, FuncMenu, Add, &s 電卓, OpenCalculator
Menu, FuncMenu, Add, &d ターミナル, OpenTerminal
Menu, FuncMenu, Add
Menu, FuncMenu, Add, &f ショートカット一覧, ShowShortcutList

;Win+L は Windows が直接ロックしてしまい「Win + 無変換 + l」（右寄せ）と両立できないので、
;起動中は Windows 側の Win+L を無効にして、代わりにこのスクリプトがロックする（終了時に元に戻す）
RegWrite, REG_DWORD, HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 1
OnExit("EnableLockWorkstation")

;緊急復帰用（フックを使わない登録方式なのでフックが外れても効く）
^!r::
    Send, {Blind}{Shift Up}{Ctrl Up}{Alt Up}{LWin Up}{RWin Up}
    Reload
return

;ロック（Windows の Win+L の代わり）
#l::
    EnableLockWorkstation()
    DllCall("LockWorkStation")
    Sleep, 1000
    RegWrite, REG_DWORD, HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 1
return

EnableLockWorkstation(){
    RegDelete, HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation
}

;方向キー
; vk1D & j::send leftじゃなくてvk1D & j::leftにしたらifいらんかも
vk1D & j::
    if (getkeystate("LWin", "P") or getkeystate("RWin", "P")){
        ;ウィンドウの最大化・最小化・左右寄せ（Shiftを足すと別のモニターへ移動）
        if getkeystate("shift", "P"){
            send #+{left}
        }else{
            send #{left}
        }
    }else if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
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
    if (getkeystate("LWin", "P") or getkeystate("RWin", "P")){
        ;ウィンドウの最大化・最小化・左右寄せ（Shiftを足すと別のモニターへ移動）
        if getkeystate("shift", "P"){
            send #+{right}
        }else{
            send #{right}
        }
    }else if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
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
    if (getkeystate("LWin", "P") or getkeystate("RWin", "P")){
        ;ウィンドウの最大化・最小化・左右寄せ（Shiftを足すと別のモニターへ移動）
        if getkeystate("shift", "P"){
            send #+{up}
        }else{
            send #{up}
        }
    }else if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
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
    if (getkeystate("LWin", "P") or getkeystate("RWin", "P")){
        ;ウィンドウの最大化・最小化・左右寄せ（Shiftを足すと別のモニターへ移動）
        if getkeystate("shift", "P"){
            send #+{down}
        }else{
            send #{down}
        }
    }else if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
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
vk1D & h::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{f5}
    }else if getkeystate("shift", "P"){
        send +{f5}
    }else if getkeystate("ctrl", "P"){
        send ^{f5}
    }else{
        send, {f5}
    }
return

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


;削除（Ctrlを足すと単語ごと）
vk1D & p::
    if getkeystate("ctrl", "P"){
        send ^{backspace}
    }else{
        send, {backspace}
    }
return

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

;検索
vk1D & f::send ^{f}

;タブ・ファイルを閉じる
vk1D & w::send ^{w}


;半角全角切り替え
vk1D & o::send, {vkF3sc029}


;テンキー
;F13を押しっぱなしにする方式だと、ロック画面やUACを挟むと押下状態がずれて
;テンキーモードが外れなくなるので、スクリプト内の変数で管理する
vkF0::
    ;押しっぱなしのキーリピートで何度も切り替わるのを防ぐ
    if (A_PriorHotkey = A_ThisHotkey and A_TimeSincePriorHotkey < 150)
        return
    numpadMode := !numpadMode
    ;オンの間はマウスの横に表示し続ける
    if (numpadMode){
        Gosub, ShowNumpadTip
        SetTimer, ShowNumpadTip, 50
    }else{
        SetTimer, ShowNumpadTip, Off
        ToolTip
    }
return

ShowNumpadTip:
    MouseGetPos, mouseX, mouseY
    ToolTip, テンキー, mouseX + 40, mouseY + 16
return

;機能メニューを開いている間は a, s, d をメニューの選択に使うので外す
#If (numpadMode and !funcMenuOpen)
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
;Ctrlを足すとタブ切り替え
vk1D & .::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{PgUp}
    }else if getkeystate("shift", "P"){
        send +{PgUp}
    }else if getkeystate("ctrl", "P"){
        send ^{PgUp}
    }else{
        send,{PgUp}
    }
return

vk1D & /::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{PgDn}
    }else if getkeystate("shift", "P"){
        send +{PgDn}
    }else if getkeystate("ctrl", "P"){
        send ^{PgDn}
    }else{
        send,{PgDn}
    }
return

;Ctrlを足すと文書の先頭・末尾
vk1D & VKBB::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{Home}
    }else if getkeystate("shift", "P"){
        send, +{Home}
    }else if getkeystate("ctrl", "P"){
        send ^{Home}
    }else{
        send, {Home}
    }
return

vk1D & VKBA::
    if (getkeystate("shift", "P") and getkeystate("ctrl", "P")){
        send +^{End}
    }else if getkeystate("shift", "P"){
        send, +{End}
    }else if getkeystate("ctrl", "P"){
        send ^{End}
    }else{
        send, {End}
    }
return

vk1D & @::send,{Insert}

;Ctrlを足すと単語ごと
vk1D & [::
    if getkeystate("ctrl", "P"){
        send ^{Delete}
    }else{
        send,{Delete}
    }
return

;shift大文字
vk1C::shift

;&を入力（変換+Shift+t）
;vk1Cをリマップと「vk1C & t」のプレフィックスに二重で使うとShiftが押しっぱなしになることがあるので、
;プレフィックスにはせず物理キーの状態で判定する
#If (getkeystate("vk1C", "P") and getkeystate("Shift", "P"))
    +t::send, {&}
#If

;機能メニュー
vk1D & vkF0::
    funcMenuOpen := true
    Menu, FuncMenu, Show
    funcMenuOpen := false
return

OpenNotepad:
    ActivateOrRun("ahk_exe Notepad.exe", "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App")
return

OpenCalculator:
    ActivateOrRun("電卓 ahk_class ApplicationFrameWindow", "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App")
return

OpenTerminal:
    ActivateOrRun("ahk_exe WindowsTerminal.exe", "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App")
return

;開いていれば前面に出し、なければ起動する
;スクリプトを管理者で動かしていると、そのまま Run したアプリも管理者になるので、
;エクスプローラー経由で起動して通常権限で開く
ActivateOrRun(winTitle, appId){
    if WinExist(winTitle){
        WinActivate
        return
    }
    Run, explorer.exe shell:AppsFolder\%appId%
}

;README.md の「操作方法」にある表を一覧にして表示する
ShowShortcutList:
    FileRead, readme, *P65001 %A_ScriptDir%\README.md
    if ErrorLevel {
        MsgBox, README.md を読み込めませんでした。
        return
    }
    Gui, Shortcuts:Destroy
    Gui, Shortcuts:Default
    Gui, Font, s10, Meiryo UI
    Gui, Add, ListView, w760 r25 Grid, 分類|キー|動作
    inSection := false
    category := ""
    Loop, Parse, readme, `n, `r
    {
        line := A_LoopField
        if (SubStr(line, 1, 3) = "## ")
            inSection := (line = "## 操作方法")
        if (!inSection)
            continue
        if (SubStr(line, 1, 4) = "### "){
            category := SubStr(line, 5)
            continue
        }
        ;表の中身の行だけ使う（見出し行と区切り行は飛ばす）
        if (SubStr(line, 1, 1) != "|" or InStr(line, "| ---") or InStr(line, "| キー |"))
            continue
        cells := StrSplit(Trim(line, "| "), "|", " ")
        ;テンキーモードの表は「キー | 入力」が横に3組並んでいるので2つずつ取り出す
        Loop % cells.Length() // 2
        {
            key := StrReplace(cells[A_Index * 2 - 1], "``")
            action := StrReplace(cells[A_Index * 2], "``")
            if (key != "")
                LV_Add("", category, key, action)
        }
    }
    LV_ModifyCol()
    Gui, Show, , ショートカット一覧
return

ShortcutsGuiEscape:
ShortcutsGuiClose:
    Gui, Shortcuts:Destroy
return
