; ----------------------------
; Comment-based language (preferred if present)
; ----------------------------

((text) @injection.content
 (#match? @injection.content "%+\\s*lang:\\s*go\\n<<[^>]+>>=\\n([\\s\\S]*?)\\n@")
 (#set! injection.language "go"))

((text) @injection.content
 (#match? @injection.content "%+\\s*lang:\\s*bash\\n<<[^>]+>>=\\n([\\s\\S]*?)\\n@")
 (#set! injection.language "bash"))

((text) @injection.content
 (#match? @injection.content "%+\\s*lang:\\s*python\\n<<[^>]+>>=\\n([\\s\\S]*?)\\n@")
 (#set! injection.language "python"))

; ----------------------------
; Fallback: extension-based
; ----------------------------

((text) @injection.content
 (#match? @injection.content "<<[^>]+\\.go>>=\\n([\\s\\S]*?)\\n@")
 (#set! injection.language "go"))

((text) @injection.content
 (#match? @injection.content "<<[^>]+\\.sh>>=\\n([\\s\\S]*?)\\n@")
 (#set! injection.language "bash"))

((text) @injection.content
 (#match? @injection.content "<<[^>]+\\.py>>=\\n([\\s\\S]*?)\\n@")
 (#set! injection.language "python"))
