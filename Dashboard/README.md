# Dashboard

'NGO Analysis dashboard v006' is the dashboard itself; report.Rmd is a parameterised R Markdown file for creating the pdf report. Data/ contains various test data -- including intentionally bad data files in Data/Bad data.

To use the dashboard with your own data:

1. Visit [proff.no](https://www.proff.no) and find the NGO you are interested in. Choose the REGNSKAP tab and save the web page as an HTML file ('source code', 'HTML only', or similar). Take note of the first and last years of available data.
2. Enter the necessary data into an Excel file using the template found in the Data folder ('NGO_template.xltx').
3. Upload both to the dashboard, making sure to enter the correct start and end years from the Proff.no web page.

If the dashboard is not available on a server you need to download 'NGO Analysis dashboard v006' and ´report.Rmd' to your computer, install [R](https://www.r-project.org) and, preferably, [RStudio](https://www.rstudio.com/products/rstudio/), and run the dashboard locally -- the easiest way being to open the dashboard file in RStudio and clicking 'Run Document'.
