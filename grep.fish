function grep --description 'Colorful grep that ignores binary file and outputs line number'
  command grep --color=always -I $argv
end
