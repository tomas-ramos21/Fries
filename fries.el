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

(defvar jar-dir nil
   "Will be assigned the path to closest target dir.")

(defvar package-name nil
  "Will be assgined the name of the current package.")

(defun fries-get-buffer-package()
  "Obtain the package of the current buffer's code."
  (setq lines (split-string (buffer-string) "\n"))
  (setq package-name nil)
  (while (and (not (eq lines nil))
              (eq package-name nil))
    (setq words (split-string (car lines) " "))
    (while (and (not (eq words nil))
                (eq package-name nil))
      (if (string= (car words) fries-package-keyword)
          (set 'package-name (car (cdr words))))
      (setq words (cdr words))
      (setq lines (cdr lines)))))

(defun fries()
  "Documentation string."
  (interactive)
  (fries-get-buffer-package)
  (message "Package: %s" )
  (set 'jar-dir (locate-dominating-file (pwd) fries-target-dir)))

(provide 'fries)
;;; fries.el ends here
