module ( "Keyboard", package.seeall )

NUMBERS = 1

getKeys = function (  )
  return {text, start, length}
end
hideKeyBoard = function (  )
end
showKeyBoard = function (  )
end
onUpdate = function (  )
end

if MOAIKeyboardIOS then
  MOAIKeyboard = MOAIKeyboardIOS
end
if MOAIKeyboardAndroid then
  MOAIKeyboard = MOAIKeyboardAndroid
end
if MOAIKeyboard then

  function onInput( s, l, t )
  end

  function onReturn ()
  end

  MOAIKeyboard.setListener ( MOAIKeyboard.EVENT_INPUT, onInput )
  MOAIKeyboard.setListener ( MOAIKeyboard.EVENT_RETURN, onReturn )
  showKeyBoard = function(string, ktype)
    if ktype and ktype == NUMBERS then
      -- API differs on platforms.
      if MOAIKeyboardAndroid then
        MOAIKeyboard.showPhoneKeyboard()
        MOAIKeyboard.setText(string)
        return
      end
      if MOAIKeyboardIOS then
        MOAIKeyboard.showKeyboard(string, MOAIKeyboardIOS.KEYBOARD_NUMERIC)
        return
      end
      return
    end
    MOAIKeyboard.showKeyboard()
  end
  hideKeyBoard = function()
    if MOAIKeyboard.hideKeyboard then
      -- This function does not exist in MOAI 1.4, which iOS is running.
      MOAIKeyboard.hideKeyboard()
    end
    text = nil
  end

  onUpdate = function()
    return MOAIKeyboard.getText()
  end
end

