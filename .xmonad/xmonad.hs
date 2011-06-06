import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

--Prefered terminal emulator
myTerminal  =   "urxvt"

myDefaults = defaultConfig {
        terminal = myTerminal
    }

myManageHook = composeAll
    [ className =? "Gimp"   --> doFloat
    , className =? "Eclipse"    --> doFloat
    , className =? "LibreOffice" --> doFloat
    ]
main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ myDefaults
        { manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask --Rebind Mod to the Windows Key
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
        , ((controlMask, xK_Print), spawn "scrot -u '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/screenshots/'")
        , ((mod4Mask .|. controlMask, xK_i), spawn "iceweasel")
        , ((0, xK_Print), spawn "scrot '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/screenshots/'")
        --Raise the Volume
        , ((0, 0x1008ff13), spawn "sh ~/scripts/xmobar/volumeUp")
        --Lower the Volume
        , ((0, 0x1008ff11), spawn "sh ~/scripts/xmobar/volumeDown")
        --Mute the Volume
        , ((0, 0x1008ff12), spawn "sh ~/scripts/xmobar/volumeMute")
        ]
