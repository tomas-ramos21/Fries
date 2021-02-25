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

(defcustom fries-javap-command "javap -c"
  "Javap command and flags use for disassembly."
  :group 'fries
  :type 'string)

(defvar buffer-lines nil)

(defun fries-get-buffer-package(keyword)
  "Obtain the word after KEYWORD of the current buffer's code."
  (save-excursion
    (goto-char (point-min))
    (let ((flag nil))
      (while (and (not (eq (point) (point-max)))
                  (eq flag nil))
        (if (string= (word-at-point) keyword)
            (set 'flag t)
            (forward-word)))
      (forward-word)
      (replace-regexp-in-string ";"
                                ""
                                (buffer-substring-no-properties
                                 (point)
                                 (point-at-eol))))))

(defun fries-get-buffer-class(keyword)
  "Obtain the word after KEYWORD of the current buffer's code."
  (save-excursion
    (goto-char (point-min))
    (let ((flag nil))
      (while (and (not (eq (point) (point-max)))
                  (eq flag nil))
        (if (string= (word-at-point) keyword)
            (set 'flag t)
            (forward-word)))
      (forward-word)
      (word-at-point))))

(defun fries()
  "Documentation string."
  (interactive)
  (let ((package (replace-regexp-in-string " " "" (fries-get-buffer-package "package")))
        (class (replace-regexp-in-string " " "" (fries-get-buffer-class "class")))
        (jar-dir (locate-dominating-file (pwd) fries-target-dir)))
    (message "Package: %s | Class: %s | JAR Dir: %s" package class jar-dir)))

(provide 'fries)
;;; fries.el ends here
