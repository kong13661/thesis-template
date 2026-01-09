#import "../consts.typ": *

#let abstract-template(info, title, abstract, keywords-title, keywords-split-char, keywords) = {
  heading(title)
  abstract
  if (keywords != none) {
    par[
    #linebreak()
    #strong(keywords-title)
    #str(
      keywords.fold(
        "",
        (str, item) => {
          if str == "" {
            str + item
          } else {
            str + keywords-split-char + item
          }
        },
      ),
    )]
  }

}

#let 中文摘要(info: (:)) = [
  #let abstract = info.at(info-keys.中文摘要)
  #let keywords = info.at(info-keys.中文摘要关键字)
  #if abstract == none or keywords == none {
    return
  }
  #abstract-template(info, "摘要", abstract, "关键词：", "，", keywords)
]

#let 英文摘要(info: (:)) = [
  #set text(region: "en", lang: "en")
  #let abstract = info.at(info-keys.英文摘要)
  #let keywords = info.at(info-keys.英文摘要关键字)
  #if abstract == none or keywords == none {
    return
  }

  #abstract-template(info, "ABSTRACT", abstract, "Keywords: ", ", ", keywords)
]
