#import "@preview/codelst:2.0.1": sourcefile

// Show subheading
#let subheading(it, size: 11pt) = {
  par(first-line-indent: 0em)[
    #text(font: "Noto Serif JP", size: size)[*#it*]
  ]
}

// Show attention to TODO
#let todo(it) = {
  text(lang: "ja", font: ("CaskaydiaCove NF", "Noto Serif JP"), fill: red)[*TODO:* *#it*]
}

// Default style for document
#let style(doc) = [
  // Text (body)
  #set text(
    lang: "ja",
    font: ("CaskaydiaCove NF", "Noto Serif JP"),
    size: 10.5pt
  )

  // Paragraph
  #set par(
    first-line-indent: 1em,
    justify: true,
    leading: 1.5em
  )

  // Heading
  #set heading(
    numbering: (..args) => {
      let nums = args.pos()
      if nums.len() == 1 {
        return numbering("1.", ..nums)
      } else {
        return numbering("1.1", ..nums)
      }
    }
  )
  #show heading: it => {
    set text(font:("CaskaydiaCove NF", "Noto Sans JP"))
    it
  }
  #show heading.where(level: 1): set text(size: 18pt)
  #show heading.where(level: 2): set text(size: 15pt)
  #show heading.where(level: 3): set text(size: 12pt)

  // Figure and Table
  #show figure.where(kind: table): set figure.caption(position: top)
  #set grid(column-gutter: 10pt, row-gutter: 10pt)

  // Code block
  #show raw: set text(lang: "ja", font: ("CaskaydiaCove NF", "Noto Serif JP"), size: 10.5pt)

  #let tbl(tbl, caption: "") = {
    figure(tbl, caption: caption, supplement: "表")
  }

  #let fig(fig, caption: "") = {
    figure(fig, caption: caption, supplement: "図")
  }

  // Regex for subheading
  #let subheading_md = "-=-"
  #show regex("^" + subheading_md + " (.*)$"): it => {
    subheading(str(it.text).slice(subheading_md.len()+1))
  }

  // Regex for TODO
  #let todo_md = "(TODO|todo)"
  #show regex(todo_md + " \S*"): it => {
    todo(str(it.text).slice(4+1))
  }

  #doc
]

// Import specific code block from file
#let showCode(
  code, 
  file,
  caption: none,
  range: none, 
  func: none, 
  class: none, 
  diff: (-1, 0),
  showrange: none,
  ..args,
) = {
  if func != none or class != none {
    let txt = code.split("\n")
    let start = 0; let end = 0; let index = none; let count = 0
    let funcName = regex(if(func!=none){("^\s*def ", func)}else{("^\s*class ", class)}.join())
    if func == "__main__" {funcName = regex("if\s+__name__\s*==")} // 特殊指定
    let spaceNum(line) = line.find(regex("(^\s*)")).len()
    for l in txt {
      count += 1
      if (funcName in l) and index == none { 
        index = spaceNum(l)
        start = count
      } else if not (regex("^\s*$") in l) and index != none and (spaceNum(l) > index) { 
        end = count
      } else if not (regex("^\s*$") in l) and index != none and (spaceNum(l) <= index) {
        break
      }
    }
    range = (start + diff.at(0), end + diff.at(1))
  }
  if showrange != none { range = showrange }
  return [
    #set block(spacing: 0.5em)
    #sourcefile(
      code,
      file: file,
      showrange: range,
      ..args,
    )
    #set align(center)
    #caption
  ]
}

// Show itembox like LaTeX
#let itembox(
  caption: none,
  space: 0pt,
  caption_padding: 0pt,
  stroke: black,
  radius: 6pt,
  inset: 8pt,
  ..args,
  body
) = [
  #block(
    stroke: stroke,
    inset: inset,
    radius: radius,
    ..args
  )[
    #context{
      stack(
        dir: ttb,
        spacing: - 1em / 2 + space,
        [
          #let place = {
              - (inset - 8pt) - 1em * 1.2 + {
              if text.size <= 8.5pt {
                - 0.2em - (8.5pt - text.size) / 1pt * 0.15em
              } else if 8.5pt <= text.size and text.size < 10.5pt {
                - 0.2em + 0.2em * ((text.size - 8.5pt) / 2pt)
              } else if 10.5pt <= text.size and text.size < 15.5pt {
                0.2em * ((text.size - 10.5pt) / 5pt)
              } else if 15.5pt <= text.size and text.size < 20.5pt {
                0.2em + 0.1em * ((text.size - 15.5pt) / 5pt)
              } else {
                0.3em + (text.size - 20.5pt) / 10pt * 0.15em
              }
            }
          }
          #move(
            dx: 0pt,
            dy: place,
          )[
            #block(
              fill: color.linear-rgb(255, 255, 255, 255),
              height: 1em,
              inset: (
                left: 3pt + caption_padding, 
                right: 3pt + caption_padding, 
                top: 0.15em, 
                bottom: 0pt
              ),
              above: 0pt,
              below: 0pt,
              [#caption]
            )
          ]
        ],
        [
          #body
        ]
      )
    }
  ]
]

