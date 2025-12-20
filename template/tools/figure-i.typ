#import "../consts.typ": *
#import "../utils/word_spacing.typ": above-leading-space, below-leading-space, 单倍行距
#let figure-kind-code = "figure-kind-code"
#let figure-kind-pic = "figure-kind-pic"
#let figure-kind-tbl = "figure-kind-tbl"

#let figure-numering(_, kind: "figure", element: none) = {
  let chapter-num = str(counter(heading.where(level: 1)).get().first())
  let loc = if element != none { element.location() } else { here() }
  let type-num = counter(kind + chapter-num).at(loc).first() + 1
  numbering("1", counter(heading.where(level: 1)).get().first()) + "-" + str(int(type-num))
}

#let pic-numering = figure-numering.with(kind: figure-kind-pic, element: none)
#let tbl-numering = figure-numering.with(kind: figure-kind-tbl, element: none)
#let code-numering = figure-numering.with(kind: figure-kind-code, element: none)

#let figure-env-set(body) = {
  set block(breakable: true)

  show figure.where(kind: figure-kind-tbl): set figure.caption(position: top)
  show figure.caption: set text(size: font-size.五号)
  // 利用 box 的自动伸缩来实现
  // 只有一行的时候居中
  // 多行左对齐
   show figure: set figure(gap: 6pt)
  // 显示的前后边距
  let figure-body(it) = {
    set par(leading: above-leading-space())
    it
  }
  // show figure: set block(above: 2em, below: 2em)
  // 图的整体间距：段前 6pt (段后由 caption 控制)
  show figure.where(kind: figure-kind-pic): set block(above: above-leading-space(space: 6pt, word-space: 单倍行距), below: below-leading-space(12pt))
  show figure.where(kind: figure-kind-tbl): set block(above: above-leading-space(space: 12pt, word-space: 单倍行距), below: below-leading-space(6pt))
  // figure 计数器自增函数
  // 图1-1 后变成 图1-2
  let count-step(kind) = {
    let chapter-num = counter(heading.where(level: 1)).get().first()
    counter(kind + str(chapter-num)).step()
  }

  show figure.caption: it => {
    let indent-width = measure(h(4em)).width
    let size = measure(it.body)
    layout(bounds => {
      let full-caption = if it.numbering != none {
              [#it.supplement#it.counter.display(it.numbering)#h(0.5em)#it.body]
            } else {
              it.body
            }
      if size.width > bounds.width - indent-width * 2 {
        set par(justify: true, leading: above-leading-space())
        box(
          width: 100%, 
          inset: (x: indent-width), // 左右缩进
          align(left, full-caption)      // 两端对齐基于左对齐基础
        )
      } else {
        set par(leading: above-leading-space())
        set align(center)
        full-caption
      }
    })
  }

  show figure: it => {
    // 修复float布局figure页面不正确的问题：https://github.com/typst/typst/issues/4359

    let space = 0pt
    if it.outlined == true {
      return it
    }

    let new-fig = none
    let content = {

      let fields = it.fields()
      let body = fields.remove("body")
      let _label = none
      if fields.keys().contains("label") {
        _label = fields.remove("label")
      }
      let counter = fields.remove("counter")


      let meta = context {
        metadata((
        figure-location: it.location(),
        body-location: here(),
        label: _label,
        ))

        let info = query(<info>).first().value
        let bottom_figure = info.at(info-keys.浮动表图标题页置底)

        let page = here().page()
        let h1-on-page = query(heading.where(level: 1))
        .any(h => h.location().page() == page)
        let should-force-bottom = false
        let next-state = should-force-bottom
        if h1-on-page and bottom_figure {
          next-state = true
        }
        let marker-lbl = label("marker-" + str(_label))
        [#metadata(next-state) #marker-lbl]
      }
      // text(num) // Force counter evaluation.
      figure(meta + body, ..fields, placement: none, outlined: true)
      count-step(it.kind)
    }

    if it.placement == none { return content }

    let fields = it.fields()
    let _label = fields.at("label")
    let should-force-bottom = false
    if _label != none {
      let key-lbl = _label
      let marker-lbl = label("marker-" + str(_label))
      let history = query(marker-lbl)
      if history.len() > 0 {
        should-force-bottom = history.last().value
      }
    }
    let placement = if should-force-bottom { bottom } else { it.placement }

    // clearance目前不支持上下控制。这个实现不能捕捉auto，两张图放在一起的情况也不能完美处理。
    let clearance = below-leading-space(12pt)
    if it.kind == figure-kind-pic {
      if placement == bottom {
        clearance = above-leading-space(space: 6pt, word-space: 单倍行距)
      }
    }
    if it.kind == figure-kind-tbl {
      if placement == bottom {
        clearance = above-leading-space(space: 12pt, word-space: 单倍行距)
      }
      if placement == top {
        clearance = below-leading-space(6pt)
      }
    }

    place(placement, float: true, clearance: clearance, scope: it.scope, block(width: 100%, content))
  }
  body
}

// #let set-placement

#let table-figure(caption, table, placement: none) = {
  figure(table, caption: caption, supplement: [表], numbering: tbl-numering, kind: figure-kind-tbl, placement: placement, outlined: false)
}

#let code-figure(caption, code, placement: none) = {
  figure(code, caption: caption, supplement: [代码], numbering: code-numering, kind: figure-kind-code, placement: placement, outlined: false)
}

#let picture-figure(caption, picture, placement: none) = {
  figure(picture, caption: caption, supplement: [图], kind: figure-kind-pic, numbering: pic-numering, placement: placement, outlined: false)
}
