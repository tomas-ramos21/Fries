;;; fries.el --- Disassemble Java byte-code for the current file
;;
;; Copyright (C) 2021 Tomas Aleixo Ramos
;;
;; Author: Tomas Ramos <https://github.com/tomas-ramos21>
;; Maintainer: Tomas Ramos <tomas.ramosv21@gmail.com>
;; Created: February 25, 2021
;; Modified: February 25, 2021
;; Version: 0.0.1
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
;;  Description
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

(defcustom fries-javap-command "javap -c -classpath"
  "Javap command and flags use for disassembly."
  :group 'fries
  :type 'string)


(defun fries-get-package()
  "Obtain the package of the code in the current buffer if there is one."
  (save-excursion
    (goto-char (point-min))
    (let ((word nil))
      (while (and (not (eobp)) (eq word nil))
        (if (string= (word-at-point) "package")
            (set' word (progn (save-excursion
                                (forward-word)
                                (buffer-substring-no-properties (point) (point-at-eol)))))
            (forward-word)))
      (car (split-string word ";")))))

(defun fries-get-byte-code(package class jar-dir)
  "Execute the javap command using PACKAGE, CLASS at JAR-DIR and display 'byte-code' in the new buffer."
  (save-buffer)
  (let ((presentation-buffer (get-buffer-create fries-bytecode-buffer))
        (disassembled-code (shell-command-to-string (concat fries-javap-command " " ))))
    (set-buffer presentation-buffer)
    (save-excursion
      (goto-char (point-min))
      (insert ADD-CODE-HERE))))

(defun fries()
  "Show the Java 'byte-code' of the class under the cursor in a new buffer."
  (interactive)
  (let ((extension (file-name-extension (buffer-file-name)))
        (package (fries-get-package))
        (class (word-at-point))
        (jar-dir (locate-dominating-file (pwd) fries-target-dir)))
    (message "%s" extension)
    (cond
     ((or (eq extension nil)
         (and (not (string= extension "java"))
              (not (string= extension "scala")))) (message "Fries: Not a Java or Scala file."))
     ((eq class nil) (message "Fries: No class detected under the cursor."))
     ((eq jar-dir nil) (message "Fries: No target directory was found. Create one or change the name of the directory containg the JAR."))
     (t (message "Package: %s | Class: %s | JAR Dir: %s" package class jar-dir)))))

(provide 'fries)
;;; fries.el ends here
