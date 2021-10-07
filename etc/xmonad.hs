import XMonad
import XMonad.Actions.CopyWindow
import XMonad.Hooks.SetWMName
import XMonad.Util.EZConfig

import Control.Monad (liftM2)
import qualified XMonad.StackSet as W

main =  xmonad $ def
  { terminal    = "kitty"
  , borderWidth = 0
  , modMask     = mod3Mask
  , startupHook = startup
  , manageHook  = windowManage
  , workspaces  = [ "1:emacs", "2:web", "3", "4", "5", "6", "7", "8", "9" ]
  } `additionalKeysP` keysP

startup = do
  setWMName "LG3D"
  spawn "xrandr --auto && xrandr --output DP-1.3 --above DP-2"
  spawn "xmodmap -e 'add mod3 = Muhenkan'"

windowManage = composeAll
  [ className =? "Emacs"                 --> doShift "1:emacs"

  , role      =? "browser"               --> doShift "2:web"

  , className =? "viewShiftW3"           --> viewShift "3"

  , className =? "Wire"                  --> doShift "8"

  , className =? ".anbox-wrapped"        --> doFloat

  , role      =? "gimp- layer-new"       --> doFloat
  , role      =? "gimp- color-selector"  --> doFloat
  , role      =? "gimp- dock"            --> doF W.focusDown
  , role      =? "gimp- toolbox"         --> doF W.focusDown
  , role      =? "toolbox_window"        --> doF W.focusDown

  , className =? "Dunst"                 --> doF W.focusDown <+> doF copyToAll
  , className =? "Pinentry"              --> doFloat <+> doF copyToAll
  ]
 where
   viewShift = doF . liftM2 (.) W.greedyView W.shift
   role = stringProperty "WM_WINDOW_ROLE"
   command = stringProperty "WM_COMMAND"

notifySend :: Integer -> String -> X ()
notifySend expireTime shellCommand = spawn 
          $ "DISPLAY=:0 notify-send -t " ++ show expireTime
          ++ " -h string:bgcolor:#000000 "
          ++ " \"$(" ++ shellCommand ++ ")\""

-- M - modMask, M1 - Alt, C - Control, S - Shift. Use xev.
keysP = [ ("M-l",                     spawn "xsecurelock")
        , ("<Print>",                 spawn "escrotum -Cs")
        , ("<XF86MonBrightnessUp>",   spawn "sudo light -A 3")
        , ("<XF86MonBrightnessDown>", spawn "sudo light -U 3")
        , ("<XF86AudioMute>",         spawn "pulsemixer --toggle-mute")
        , ("<XF86AudioLowerVolume>",  spawn "pulsemixer --change-volume -3")
        , ("<XF86AudioRaiseVolume>",  spawn "pulsemixer --change-volume +3")
        , ("M-d",                     notifySend 3000 "date && TZ='Europe/Paris' date && TZ='Europe/Moscow' date")
        , ("M-p",                     spawn "rofi -theme android_notification -font 'Ubuntu Mono 30' -show run")
        , ("M-s",                     spawn "kitty")
        , ("M-b",                     notifySend 1000 "acpi -b")
        ]
        ++
        [ (mask ++ "M-" ++ [key], screenWorkspace scr >>= flip whenJust (windows . action))
          | (key, scr)  <- zip "wer" [1,0,0] -- was [0..] *** change to match your screen order ***
          , (action, mask) <- [ (W.view, "") , (W.shift, "S-")]
        ]
