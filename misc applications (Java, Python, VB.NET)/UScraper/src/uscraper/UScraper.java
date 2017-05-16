/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package uscraper;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlPage;
import com.gargoylesoftware.htmlunit.html.HtmlSubmitInput;
import com.gargoylesoftware.htmlunit.html.HtmlHiddenInput;
import com.gargoylesoftware.htmlunit.html.HtmlPasswordInput;
import com.gargoylesoftware.htmlunit.html.HtmlTextInput;
import com.gargoylesoftware.htmlunit.html.HtmlAnchor;
import com.gargoylesoftware.htmlunit.html.HtmlForm;
import com.gargoylesoftware.htmlunit.html.HtmlElement;
import com.gargoylesoftware.htmlunit.html.HtmlDivision;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import java.io.FileOutputStream;
import java.io.File;
import java.util.*; 
import java.util.List;
import com.gargoylesoftware.htmlunit.javascript.background.JavaScriptJobManager;
import java.text.SimpleDateFormat;

public class UScraper {
    private static WebClient webClient;
    private static HtmlPage page;
    private static HtmlPage retpage;
    private static int itemNo = 15;
    private static FileOutputStream outstream;
    private static XSSFWorkbook workbook;
    private static XSSFSheet sheet;
    private static XSSFRow row;
    private static XSSFCell cell;

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        String[] states = {"California,", "Alabama,", "Arkansas,", "Arizona,", "Alaska,", "Colorado,", "Connecticut,", "Delaware,", "Florida,", "Georgia,", "Hawaii,", "Idaho,", "Illinois,", "Indiana,", "Iowa,", "Kansas,", "Kentucky,", "Louisiana,", "Maine,", "Maryland,", "Massachusetts,", "Michigan,", "Minnesota,", "Mississippi,", "Missouri,", "Montana,", "Nebraska,", "Nevada,", "New Hampshire,", "New Jersey,", "New Mexico,", "New York,", "North Carolina,", "North Dakota,", "Ohio,", "Oklahoma,", "Oregon,", "Pennsylvania,", "Rhode Island,", "South Carolina,", "South Dakota,", "Tennessee,", "Texas,", "Utah,", "Vermont,", "Virginia,", "Washington,", "West Virginia,", "Wisconsin,", "Wyoming" };
        String path = System.getProperty("user.home") + "/Documents/careerbuider.xlsx";
        CareerBuilderScraper(path,10,states);
        System.out.println("Done!");
    }  
    public static void setLoggerOff() {
        java.util.logging.Logger.getLogger("com.gargoylesoftware.htmlunit").setLevel(java.util.logging.Level.OFF);
        java.util.logging.Logger.getLogger("org.apache.http").setLevel(java.util.logging.Level.OFF);
    }
    public static void CareerBuilderScraper(String path, int totalPage, String[] states) {
        setLoggerOff();

        try {
            outstream = new FileOutputStream(new File(path));
            workbook = new XSSFWorkbook();
            sheet = workbook.createSheet("CareerBuilder");
    
            webClient = new WebClient();
            webClient.getOptions().setJavaScriptEnabled(false);
            webClient.getOptions().setTimeout(86400000);// 1 day
            page = webClient.getPage("http://www.careerbuilder.com/");
            
            HtmlForm form = page.getFirstByXPath("//form[@action='http://www.careerbuilder.com/jobs']");
            HtmlElement button = (HtmlElement) page.createElement("button");
            button.setAttribute("type", "submit");
            form.appendChild(button);
            
            HtmlTextInput what = (HtmlTextInput) page.getElementByName("keywords");
            HtmlTextInput where = (HtmlTextInput) page.getElementByName("location");
            what.setValueAttribute("");
            
            for (String state:states) {
                where.setValueAttribute(state);
                //where.setValueAttribute("Connecticut");
                //System.out.println(page.asXml());System.exit(0);
                page = button.click();
                webClient.waitForBackgroundJavaScript(1000);
                int pageNum = 1;
                int rowNum = 0;
                while (pageNum <= totalPage) {
                    List<?> aTitle = page.getByXPath("//div[@class='job-row']/div/div/h2/a");
                    for (int i = 0; i < aTitle.size(); i++) {
                        HtmlAnchor a = (HtmlAnchor) aTitle.get(i);
                        XSSFRow row = (XSSFRow) sheet.createRow(rowNum);
                        XSSFCell cellSource = row.createCell(0);
                        cellSource.setCellValue("CareerBuilder");
                        XSSFCell cellTitle = row.createCell(1);
                        cellTitle.setCellValue(a.asText());

                        HtmlPage descriptionPage = a.click();
                        webClient.waitForBackgroundJavaScript(1000);
                        HtmlDivision div = (HtmlDivision) descriptionPage.getByXPath("//div[@class='description']").get(0);
                        XSSFCell cellDesc = row.createCell(8);
                        cellDesc.setCellValue(div.asText());

                        rowNum++;
                    }
                    
                    webClient.waitForBackgroundJavaScript(1000);
                    List<?> hCompany = page.getByXPath("//div[@class='job-row']/div/div[@class='columns large-2 medium-3 small-12']/h4");
                    rowNum = 0;
                    for (int i = 0; i < hCompany.size(); i++) {
                        HtmlElement e = (HtmlElement) hCompany.get(i);
                        XSSFRow row = (XSSFRow) sheet.getRow(rowNum);
                        XSSFCell cellCompany = row.createCell(2);
                        cellCompany.setCellValue(e.asText());

                        rowNum++;
                    }

                    webClient.waitForBackgroundJavaScript(1000);
                    List<?> hLocation = page.getByXPath("//div[@class='job-row']/div[@class='row job-information']/div[@class='columns end large-2 medium-3 small-12']/h4[@class='job-text']");
                    rowNum = 0;
                    for (int i = 0; i < hLocation.size(); i++) {
                        HtmlElement e = (HtmlElement) hLocation.get(i);
                        XSSFRow row = (XSSFRow) sheet.getRow(rowNum);
                        XSSFCell cellLocation = row.createCell(3);
                        cellLocation.setCellValue(e.asText());
                        System.out.println(row.getCell(3));

                        rowNum++;
                    }

                    webClient.waitForBackgroundJavaScript(1000);
                    List<?> hInfo = page.getByXPath("//div[@class='job-row']/div/div[@class='columns medium-6 large-8']/h4");
                    rowNum = 0;
                    for (int i = 0; i < hInfo.size(); i++) {
                        HtmlElement e = (HtmlElement) hInfo.get(i);
                        XSSFRow row = (XSSFRow) sheet.getRow(rowNum);
                        XSSFCell cellInfo = row.createCell(4);
                        cellInfo.setCellValue(e.asText());

                        rowNum++;
                    }

                    webClient.waitForBackgroundJavaScript(1000);
                    List<?> emElapsedTime = page.getByXPath("//div[@class='job-row']/div/div/div[@class='show-for-medium-up']/em");
                    rowNum = 0;
                    for (int i = 0; i < emElapsedTime.size(); i++) {
                        HtmlElement e = (HtmlElement) emElapsedTime.get(i);
                        XSSFRow row = (XSSFRow) sheet.getRow(rowNum);
                        XSSFCell cellElapsedTime = row.createCell(5);
                        cellElapsedTime.setCellValue(e.asText());

                        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(Calendar.getInstance().getTime());
                        XSSFCell cellDateTime = row.createCell(6);
                        cellDateTime.setCellValue(timeStamp);
                        XSSFCell cellState = row.createCell(7);
                        cellState.setCellValue(state);

                        rowNum++;
                    }

                    HtmlAnchor next = (HtmlAnchor) page.getElementById("next-button");
                    next.click();
                    pageNum++;
                }
            }
            workbook.write(outstream);
        }
        catch (Exception e) {
            e.printStackTrace();
        } 
        finally {
            try {
                if (workbook != null) workbook.close();
                if (outstream != null) outstream.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        return;
    }
    public static void IndeedScraper() {
        setLoggerOff();
        try {
            webClient = new WebClient();
            webClient.getOptions().setJavaScriptEnabled(false);
            page = webClient.getPage("http://www.indeed.com/");
            HtmlTextInput what = (HtmlTextInput) page.getElementById("what");
            HtmlTextInput where = (HtmlTextInput) page.getElementById("where");
            HtmlSubmitInput find = (HtmlSubmitInput) page.getElementById("fj");
            what.setValueAttribute("");
            where.setValueAttribute("MA,US");
            HtmlPage page =find.click(1,1);
            
            JavaScriptJobManager manager = page.getEnclosingWindow().getJobManager();
            while (manager.getJobCount() > 0) {
                Thread.sleep(1000);
            }
            List<?> aTitle = page.getByXPath("//div/h2/a");
            for (int i = 0; i < aTitle.size(); i++) {
                HtmlAnchor a = (HtmlAnchor) aTitle.get(i);
                //System.out.println(a.getAttribute("title"));
                System.out.println(aTitle.get(i).toString());
                HtmlPage descriptionPage = a.click();
                JavaScriptJobManager submanager = descriptionPage.getEnclosingWindow().getJobManager();
                while (submanager.getJobCount() > 0) {
                    Thread.sleep(1000);
                }
                
            }
           }
        catch (Exception e) {
            e.printStackTrace();
        } 
        return;
    }
}

