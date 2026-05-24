set -o vi

resync() {
  # 1. Save the current terminal state (baud rate, parity, etc.)
  old=$(stty -g)
  # 2. Put terminal in 'raw' mode so it doesn't process the response as typing
  stty raw -echo min 0 time 1
  # 3. Send the "Report Terminal Window Size" escape sequence
  printf '\033[18t'
  # 4. Read the response from the terminal (Format: \033[8;rows;cols;t)
  IFS=';t' read -r -d t _ rows cols _
  # 5. Restore the terminal to its original state
  stty "$old"
  # 6. Manually force the kernel/shell to recognize the new dimensions
  stty rows "$rows" cols "$cols"
}

resync


