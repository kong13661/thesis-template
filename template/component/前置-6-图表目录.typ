// https://github.com/typst/typst/discussions/4515
#import "../consts.typ": *
#import "../tools/figure-i.typ": *

#let 图表目录(info: (:)) = [

#set par(leading: above-leading-space())
#show outline.entry: it => {
  // 定义空隙宽度，方便统一调整
  let gap = 1.5em 
  link(it.element.location())[
    #grid(
      columns: (3.5em, 1fr, gap),
      // stroke: 0.5pt,
      gutter: 0pt, // 关键：左右栏必须紧贴，物理间隙为0
      it.prefix(),
      [#it.body()
       #box(width: 1fr, clip: false)[
            #box(width: 100% + gap)[
                  #set text(top-edge: 0em)
                  #box(width: 1fr, it.fill)
                  #it.page()
              ]
          ]
      ]
    )
  ]
}
  #outline(
    title: "插图清单", 
    target: figure.where(kind: figure-kind-pic),
    indent: 2em, // 这是一个排版优化，让条目稍微缩进一点
  )
  #outline(
    title: "表格清单", 
    target: figure.where(kind: figure-kind-tbl),
    indent: 2em
  )
  
  #pagebreak(weak: true)
  #if info.at(info-keys.打印模式) {
    pagebreak(weak: true, to: "odd")
  }
]