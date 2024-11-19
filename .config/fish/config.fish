if status is-interactive
    # Установка русского языка как системного
    set -x LANG ru_RU.UTF-8
    
    eval (ssh-agent -c)

    # Commands to run in interactive sessions can go here
end
