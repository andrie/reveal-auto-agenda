exp <- '
<section class="title-slide slide level1 agenda-slide center">
<h1>First</h1>
<div class="agenda">
<ul>
<li><div class="agenda-active">
<p>First</p>
</div></li>
<li><p>Second</p></li>
</ul>
</div>
</section>
'
  
test_that("rendering works", {
  quarto_render("test.qmd") 
  expect_true(
    quarto_expect_text("test.html", exp)
  )
})
