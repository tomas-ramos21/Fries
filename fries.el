;;; fries.el --- Disassemble Java byte-code for the current file
;;
;; Copyright (C) 2021 Tomas Aleixo Ramos
;;
;; Author: Tomas Ramos <https://github.com/tomas-ramos21>
;; Maintainer: Tomas Ramos <tomas.ramosv21@gmail.com>
;; Created: February 25, 2021
;; Modified: February 25, 2021
;; Version: 0.1.0
;; Keywords: tools
;; Homepage: https://github.com/tomas-ramos21/Fries
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;;  Fries lets you see the disassembled Java "byte-code" of the class under
;;  under the cursor in a new buffer. If you have "javap-mode" installed it
;;  will even highlight the dissassembled code for you.
;;
;;  It works by detecting the package of the class, the closest "target" directory,
;;  and then the JAR file within it or it's sub-directories. After that it will
;;  use the shell command "javap" along with some arguments to obtain the code.
;;  If no classes are found with the name under the cursor it will show you the
;;  error message provided by the "javap" command.
;;
;;; Code:

(defgroup fries nil
  "Disassemble Java byte-code of the current buffer."
  :prefix "fries-"
  :group 'tools)

(defcustom fries-target-dir "target"
  "Name of the directory expected to contain the JAR file."
  :group 'fries
  :type 'string)

(defcustom fries-package-keyword "package"
  "Expected keyword identifying the package."
  :group 'fries
  :type 'string)

(defcustom fries-bytecode-buffer "*Byte-Code*"
  "Name for the buffer used to display the 'byte-code'."
  :group 'fries
  :type 'string)

(defcustom fries-javap-command "javap -l -c -p -s -constants -verbose -classpath"
  "Javap command and flags used for disassembly."
  :group 'fries
  :type 'string)

(defcustom fries-unsupported-file "Fries: Not a Java or Scala file."
  "Message displayed for wrong file extension."
  :group 'fries
  :type 'string)

(defcustom fries-no-class-under-cursor "Fries: No class detected under the cursor."
  "Message displayed when no text is found under the cursor."
  :group 'fries
  :type 'string)

(defcustom fries-target-dir-not-found "Fries: No target directory was found. Create one or change the name of the directory containing the JAR."
  "Message displayed when the JAR directory or one of it's parents is not found."
  :group 'fries
  :type 'string)

(defcustom fries-no-jars-found "Fries: No JAR files were found. Did you compile?"
  "Message displayed when no JAR files are found."
  :group 'fries
  :type 'string)

(defun fries-get-package()
  "Locate the 'package' keyword and obtain package of the code in the buffer."
  (save-excursion
    (goto-char (point-min))
    (let ((word nil))
      (while (and (not (eobp)) (eq word nil))
        (if (string= (current-word) "package")
            (set' word (progn (save-excursion
                                (forward-word)
                                (buffer-substring-no-properties (point) (point-at-eol)))))
            (forward-word)))
      (if (not (eq word nil))
          (car (split-string word ";"))))))

(defun fries-get-jar-path(jar-dir)
  "Locate the JAR file within JAR-DIR or it's sub-directories."
  (let ((files (directory-files-recursively jar-dir "\\.jar$")))
    (car files)))

(defun fries-get-byte-code(package class jar-path)
  "Execute the javap command using PACKAGE, CLASS at JAR-PATH and display 'byte-code' in the new buffer."
  (save-buffer)
  (let ((presentation-buffer (get-buffer-create fries-bytecode-buffer))
        (current-dir (file-name-directory (car (split-string (buffer-file-name) " ")))))
    (if (eq jar-path nil)
        (message fries-no-jars-found)
        (progn
          (if (eq nil (get-buffer-window fries-bytecode-buffer))
              (select-window (split-window-below))
              (select-window (get-buffer-window fries-bytecode-buffer)))
          (switch-to-buffer presentation-buffer)
          (cd (file-name-directory jar-path))
          (save-excursion
            (goto-char (point-min))
            (erase-buffer)
            (if (not (eq nil (symbol-file 'javap-mode)))
                (with-current-buffer presentation-buffer (javap-mode)))
            (with-current-buffer presentation-buffer (linum-mode))
            (if (eq package nil)
                (insert (shell-command-to-string
                         (concat fries-javap-command " " (file-name-nondirectory jar-path) " " class)))
                (insert (shell-command-to-string
                         (concat fries-javap-command " " (file-name-nondirectory jar-path) " "
                                 (concat (replace-regexp-in-string "\\." "/" package) "/" class)))))
            (goto-char (point-min))
            (while (not (eobp))
              (insert " ")
              (forward-line)))))))

(defun fries()
  "Show the Java 'byte-code' of the class under the cursor in a new buffer."
  (interactive)
  (let ((extension (file-name-extension (buffer-file-name)))
        (package (fries-get-package))
        (class (current-word))
        (jar-dir (locate-dominating-file (pwd) fries-target-dir)))
    (cond
     ((or (eq extension nil)
         (and (not (string= extension "java"))
              (not (string= extension "scala")))) (message fries-unsupported-file))
     ((eq class nil) (message fries-no-class-under-cursor))
     ((eq jar-dir nil) (message fries-target-dir-not-found))
     (t (fries-get-byte-code package class (fries-get-jar-path jar-dir))))))

(provide 'fries)
;;; fries.el ends here
