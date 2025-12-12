#import "../consts.typ": *
#import "../tools/figure-i.typ": *

#let 目录(info: (:)) = [
  #set align(center)
  
  #set par(leading: above-leading-space()) // 设置条目行距
  #set outline.entry(fill: repeat(text(top-edge: 0em)[.], gap: 0.15em))

  #show outline.entry.where(level: 1): it => {
    let prefix = if it.prefix() != none {
        strong(it.prefix())
      } else {
        h(-0.5em)
      }
    it.indented(
      prefix,
      [#strong(it.body())
       #box(width: 1fr, it.fill)
       #it.page()],
      gap: 0.5em
    )
  }
  #heading("目 录")
  #outline(title: none, depth: 3, indent: 2em)

  #set page(header: none, footer: none)
  #pagebreak(weak: true)
  #if info.at(info-keys.打印模式) {
    pagebreak(weak: true, to: "odd")
  }
]
