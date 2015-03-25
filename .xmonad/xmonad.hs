import System.IO
import System.Exit

import XMonad hiding (Tall)
import XMonad.ManageHook
import XMonad.Prompt
import XMonad.Prompt.Shell

import Control.Monad (liftM2)

import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicHooks

import XMonad.Layout.ComboP
import XMonad.Layout.LayoutCombinators hiding ((|||))
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.TwoPane
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.Accordion
import XMonad.Layout.Fullscreen
import XMonad.Layout.ResizableTile

import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS
import XMonad.Actions.FloatKeys

import XMonad.Util.Run(spawnPipe)

import qualified XMonad.StackSet as W

import Graphics.X11
import Graphics.X11.Xinerama

import qualified Data.Map as M
import Data.Monoid

--main = do
--    xmproc <- spawnPipe "xmobar ~/.xmobarrc"
--    xmonad $ defaultConfig {
--        logHook = dynamicLogWithPP $ xmobarPP {
--            ppOutput = hPutStrLn xmproc,
--            ppTitle = xmobarColor "green" "" . shorten 50
--        }
--        , startupHook = setWMName "LG3D"
--        , manageHook = myManageHook <+> manageDocks <+> dynamicMasterHook
--        , layoutHook = myLayout
--       , keys = myKeys
--        , terminal = myTerminal
--        , borderWidth = myBorderWidth
--        , modMask = myModMask
--        , workspaces = myWorkspaces
--        , normalBorderColor = myNormalBorderColor
--        , focusedBorderColor = myFocusedBorderColor
--    }

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig
myBar = "xmobar"
-- Custom PP
myPP = xmobarPP {
    ppCurrent = xmobarColor "green" "" . wrap "<" ">"
    , ppHidden = xmobarColor "#C98F0A" ""
    , ppUrgent = xmobarColor "#FFFFAF" "" . wrap "[" "]" 
    , ppLayout = xmobarColor "#ffffff" "" . shorten 8
    , ppTitle =  xmobarColor "#C9A34E" "" . shorten 70
    , ppSep = xmobarColor "#429942" "" " | "
}

-- Key binding to toggle the gap for the bar
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)
myConfig = defaultConfig {
     startupHook = setWMName "LG3D"
    , manageHook = myManageHook <+> manageDocks <+> dynamicMasterHook
    , layoutHook = myLayout
    , keys = myKeys
    , terminal = myTerminal
    , borderWidth = myBorderWidth
    , modMask = myModMask
    , workspaces = myWorkspaces
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
}

-- Preferred terminal
myTerminal = "/usr/bin/urxvt"
myBorderWidth = 1
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
myModMask = mod4Mask
myNumlockMask = mod2Mask
-- Workspaces
myWorkspaces = ["1:term", "2:web"] ++ map show [3..9]

-- Border Colors
myNormalBorderColor = "#E77300"
myFocusedBorderColor = "E70000"

myManageHook = composeAll . concat $
    [ [isDialog --> doFloat]
    , [className =? c --> doFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myRIgnores]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift
        (myWorkspaces !! 0) | x <- myTerm]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift
        (myWorkspaces !! 1) | x <- myWeb]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift
        (myWorkspaces !! 2) | x <- myWork2]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift
        (myWorkspaces !! 3) | x <- myWork3]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShift
        (myWorkspaces !! 4) | x <- myWork4]
    , [className =? c --> doCenterFloat | c <- myCCenter]
    , [name =? n --> doCenterFloat | n <- myNCenter]
    , [className =? c --> doF W.focusDown | c <- myCFocusD]
    , [isFullscreen --> doFullFloat]
    ] where
        name = stringProperty "WM_NAME"
        myCFloats = ["MPlayer", "vlc", "Gimp", "Xmessage"]
        myTFloats = []
        myRFloats = []
        myRIgnores = ["Trayer"]
        myTerm = []
        myWeb = ["Google-chrome"]
        myWork2 = ["Pidgin"]
        myWork3 = ["Eclipse"]
        myWork4 = ["VirtualBox"]
        myCCenter = []
        myNCenter = []
        myCFocusD = []

myLayout = avoidStruts $ smartBorders (resizableTile ||| Full ||| Grid ||| Accordion
    ||| noBorders (fullscreenFull Full))
    where
        resizableTile = ResizableTall nmaster delta ratio []
        --tiled = Tall nmaster delta ratio
        nmaster = 1
        ratio = 1/2
        delta = 3/100

myGSConfig = defaultGSConfig
    { gs_cellheight = 50
    , gs_cellwidth = 250
    , gs_cellpadding = 10
    }

myXPConfig = defaultXPConfig

-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
 
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
 
    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
 
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Bind keys 
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    
    [ ((modMask, xK_p), shellPrompt myXPConfig)
	-- launch firefox
    , ((modMask,                 xK_i), spawn "google-chrome")
    -- Take screenshot of focused wondow
    , ((controlMask, xK_Print), spawn "scrot -u screen_%Y-%m-%d.png -d 1")
    , ((0, xK_Print), spawn "scrot screen_%Y-%m-%d.png -d 1")
    -- lock
    , ((modMask .|. controlMask, xK_l), spawn "xscreensaver-command -lock")
    , ((modMask, xK_Tab), windows W.focusDown) -- move focus to the next window
    , ((modMask, xK_j), windows W.focusDown) -- move focus to the next window
    , ((modMask, xK_k), windows W.focusUp) -- move focus to the previous window
    , ((modMask, xK_b), sendMessage ToggleStruts) -- toggle the statusbar gap
    -- move focus to the master
    , ((modMask, xK_m), windows W.focusMaster)
    -- increment the number of windows in the master area
    , ((modMask, xK_comma), sendMessage (IncMasterN 1))
    -- deincrement the number of windows in the master area
    , ((modMask, xK_period), sendMessage (IncMasterN (-1)))
    -- Swap focused and master window
    , ((modMask, xK_Return), windows W.swapMaster)
    -- rotate through the available layout algorithms
    , ((modMask, xK_space), sendMessage NextLayout)
    -- display grid select and goto selected window
    , ((modMask, xK_g), goToSelected myGSConfig)
    , ((modMask, xK_Left), prevWS) -- switch to previous workspace
    , ((modMask, xK_Right), nextWS) -- switch to next workspace
    -- move focus to the previous window
    , ((modMask .|. shiftMask, xK_Tab), windows W.focusUp) 
    -- display grid select and go to selected workspace
    --, ((modMask .|. shiftMask, xK_g), gridselectWorkspace myGSConfig W.view)
    -- shrink master area
    , ((modMask, xK_h), sendMessage Shrink)
    -- swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j), windows W.swapDown)
    -- swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k), windows W.swapUp)
    -- expand the master area
    , ((modMask, xK_l), sendMessage Expand)
    -- move focus to urgent window
    --, ((modMask .|. shiftMask, xK_Return), focusUrgent)
    , ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- quit xmonad
    , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))
    -- restart xmonad
    , ((modMask, xK_q), restart "xmonad" True)
    -- push window back into tiling
    , ((modMask .|. controlMask, xK_d), withFocused $ windows . W.sink)
    --reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    -- expand the height/width
    , ((modMask .|. controlMask, xK_h), sendMessage MirrorExpand)
    -- swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j), windows W.swapDown)
    -- swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k), windows W.swapUp)
    -- shrink the height/width
    , ((modMask .|. controlMask, xK_l), sendMessage MirrorShrink)
    -- close ficused window
    , ((modMask .|. shiftMask, xK_c), kill)
    -- move floated window 10 pixels left
    , ((modMask .|. controlMask, xK_Left), withFocused (keysMoveWindow (-30,0)))
    -- move floated window 10 pixels right
    , ((modMask .|. controlMask, xK_Right), withFocused (keysMoveWindow (30,0)))
    -- move floated window 10 pixels up
    , ((modMask .|. controlMask, xK_Up), withFocused (keysMoveWindow (0,-30)))
    -- move floated window 10 pixels down
    , ((modMask .|. controlMask, xK_Down), withFocused (keysMoveWindow (0,30)))
    -- lock
    , ((modMask .|. controlMask, xK_l), spawn "xscreensaver-command -lock")
	--XF86AudioMute
	, ((0, 0x1008ff12), spawn "sh ~/scripts/xmobar/volumeMute")
	--XF86AudioRaiseVolume
	, ((0, 0x1008ff13), spawn "sh ~/scripts/xmobar/volumeUp")
	--XF86AudioLowerVolume
	, ((0, 0x1008ff11), spawn "sh ~/scripts/xmobar/volumeDown")
    --XF86AudioPlay
    , ((0, 0x1008ff14), spawn "mpc toggle")
    --XF86Battery
    , ((0, 0x1008ff93), spawn "sh ~/scripts/battery")
	--Switch to swedish layout and back to normal
    , ((modMask .|. controlMask, xK_z), spawn "sh ~/scripts/swedish_locale")
    ]
    ++
    [ ((m .|. modMask, k), windows $ f i)
        -- mod-[1..9],switch to workspace n
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9] 
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
        -- mod-shift-[F1..F9], move window to workspace n
        --, (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
    ]
    ++
    [ ((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        -- mod-{F10,F11,F12}, switch to physical/Xinerama screens 1, 2, or 3
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        -- mod-shift-{F10,F11,F12}, move window to screen 1, 2, or 3
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)] 
    ]
