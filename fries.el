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
  "Javap command and flags used for disassembly."
  :group 'fries
  :type 'string)

(defun fries-get-package()
  "Locate the 'package' keyword and obtain package of the code in the buffer."
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

(defun fries-get-jar-path(jar-dir)
  "Locate the JAR file within JAR-DIR or it's sub-directories."
  (let ((files (directory-files-recursively jar-dir "\\.jar$")))
    (car files)))

(defun fries-get-byte-code(package class jar-path)
  "Execute the javap command using PACKAGE, CLASS at JAR-PATH and display 'byte-code' in the new buffer."
  (save-buffer)
  (let ((presentation-buffer (get-buffer-create fries-bytecode-buffer))
        (current-dir (file-name-directory (car (split-string (buffer-file-name) " ")))))
    (if (eq nil (get-buffer-window fries-bytecode-buffer))
        (select-window (split-window-below))
        (select-window (get-buffer-window fries-bytecode-buffer)))
    (switch-to-buffer presentation-buffer)
    (cd (file-name-directory jar-path))
    (save-excursion
      (goto-char (point-min))
      (erase-buffer)
      (with-current-buffer presentation-buffer (javap-mode))
      (with-current-buffer presentation-buffer (linum-mode))
      (insert (shell-command-to-string
               (concat fries-javap-command " " (file-name-nondirectory jar-path) " "
                       (concat (replace-regexp-in-string "\\." "/" package) "/" class)))))))

(defun fries()
  "Show the Java 'byte-code' of the class under the cursor in a new buffer."
  (interactive)
  (let ((extension (file-name-extension (buffer-file-name)))
        (package (fries-get-package))
        (class (word-at-point))
        (jar-dir (locate-dominating-file (pwd) fries-target-dir)))
    (cond
     ((or (eq extension nil)
         (and (not (string= extension "java"))
              (not (string= extension "scala")))) (message "Fries: Not a Java or Scala file."))
     ((eq class nil) (message "Fries: No class detected under the cursor."))
     ((eq jar-dir nil) (message "Fries: No target directory was found. Create one or change the name of the directory containing the JAR."))
     (t (fries-get-byte-code package class (fries-get-jar-path jar-dir))))))

(provide 'fries)
;;; fries.el ends here
