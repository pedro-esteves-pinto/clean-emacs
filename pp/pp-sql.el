;;; pp-sql.el --- SQL configuration

(use-package sql
  :straight (:type built-in)
  :defer t
  :config
  (setq sql-ms-program "sqlcmd")
  (setq sql-ms-options '("-w" "300"))
  (load "pp-connections" t))

(provide 'pp-sql)
