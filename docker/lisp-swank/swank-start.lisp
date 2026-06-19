;;; Swank server startup for use with Conjure (Olical/conjure).
;;;
;;; :interface "0.0.0.0"
;;; ---------------------
;;; Docker port-forwarding routes connections from the host to the
;;; container's eth0 network interface (e.g. 172.17.0.2), not to the
;;; container's loopback (127.0.0.1).  Swank's default :interface is
;;; "127.0.0.1", so without this flag host connections are refused at the
;;; TCP level and Conjure never receives a response — the HUD stays empty.
;;;
;;; *use-dedicated-output-stream* nil
;;; -----------------------------------
;;; With the default value of T, Swank opens a second TCP socket for
;;; output and announces its port via :new-port immediately after a client
;;; connects.  Conjure's Common Lisp client does not implement that
;;; two-connection handshake; it stops reading from the control socket,
;;; Swank reads EOF, and logs "close-connection: end of file".
;;;
;;; The symbol is internal to the :swank package (not exported), so
;;; double-colon notation is required.  ignore-errors is a safety net in
;;; case a future Swank release renames or removes the variable — the
;;; server starts regardless.

(ql:quickload :swank)

(ignore-errors
  (setf swank::*use-dedicated-output-stream* nil))

(swank:create-server :port 4005
                     :dont-close t
                     :style :spawn
                     :interface "0.0.0.0")

;;; Block the main thread so the container keeps running.
;;; Swank handles each client connection in its own thread (:style :spawn).
(loop (sleep 60))
