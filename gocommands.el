(require 'go-mode)

(defvar gobin "go")

(defun find-go-root (fn)
  (when (not (or (string= fn "/") (string= fn "")))
    (let* ( (parent (file-name-directory (directory-file-name fn)))
	    (pn (file-name-nondirectory (directory-file-name fn))) )
      (if (string= pn "src")
	  parent
	(find-go-root parent)))))

(defun go-package-path (fn)
  (let* ((d (file-name-directory fn))
	(r (format "%ssrc" (find-go-root fn))))
    (substring d (+ (length r) 1) -1)))

(defun go-build ()
  (interactive)
  (let ((gopath (find-go-root (buffer-file-name))))
  (compile (format "GOPATH=\"%s\" %s build \"%s\""
		   gopath
                   gobin
		   (go-package-path (buffer-file-name))))))

(defun go-test ()
  (interactive)
  (let ((gopath (find-go-root (buffer-file-name))))
    (compile (format "GOPATH=\"%s\" %s test \"%s\""
		   gopath
                   gobin
		     (go-package-path (buffer-file-name))))))

(defun go-install ()
  (interactive)
  (let ((gopath (find-go-root (buffer-file-name))))
    (compile (format "GOPATH=\"%s\" %s install \"%s\""
		     gopath
                     gobin
		     (go-package-path (buffer-file-name))))))

(defun go-run ()
  (interactive)
  (let ((gopath (find-go-root (buffer-file-name))))
    (compile (format "GOPATH=\"%s\" %s run \"%s\""
		     gopath
                     gobin
		     (buffer-file-name)))))

(define-key go-mode-map "\C-xgb" 'go-build)
(define-key go-mode-map "\C-xgt" 'go-test)
(define-key go-mode-map "\C-xgi" 'go-install)
(define-key go-mode-map "\C-xgr" 'go-run)

(easy-menu-define
 go-mode-menu go-mode-map
 "Menu for Go files."
 '("Go"
   ["Build" go-build]
   ["Test" go-test]
   ["Install" go-install]
   ["Run" go-run]))

(if (boundp 'image-load-path)
    (add-to-list 'image-load-path (file-name-directory load-file-name)))

(defvar go-mode-tool-bar-map
  ;; When bootstrapping, tool-bar-map is not properly initialized yet,
  ;; so don't do anything.
  (when (keymapp (butlast tool-bar-map))
    (let ((map (butlast (copy-keymap tool-bar-map)))
          (help (last tool-bar-map))) ;; Keep Help last in tool bar
      (tool-bar-local-item
       "run-build-2" 'go-build 'go-build map
       :help "Go build")
      (tool-bar-local-item
       "run-build-configure" 'go-test 'go-test map
       :help "Go test")
      (tool-bar-local-item
       "run-build-install" 'go-install 'go-install map
       :help "Go install")
      (tool-bar-local-item
       "media-playback-start-3" 'go-run 'go-run map
       :help "Go run")
      (append map help))))

(add-hook 'go-mode-hook
	  (lambda ()
	    (set (make-local-variable 'tool-bar-map) go-mode-tool-bar-map)
	    ))
