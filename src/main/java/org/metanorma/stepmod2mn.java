package org.metanorma;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.util.List;
import java.util.Scanner;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.xml.sax.InputSource;
import org.xml.sax.SAXParseException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

/**
 * This class for the conversion of an NISO/ISO XML file to Metanorma XML or AsciiDoc
 */
public class stepmod2mn {

    static final String CMD = "java -jar stepmod2mn.jar <resource_xml_file> [options -o, -v, -b <path>]";
    static final String CMD_SVGscope = "java -jar stepmod2mn.jar <start folder to process xml maps files> --svg";
    static final String CMD_SVG = "java -jar stepmod2mn.jar --xml <Express Imagemap XML file path> --image <Image file name> [--svg <resulted SVG map file or folder>] [-v]";
    
    static final String INPUT_NOT_FOUND = "Error: %s file '%s' not found!";    
    static final String INPUT_PATH_NOT_FOUND = "Error: %s path '%s' not found!";    
    static final String XML_INPUT = "XML";    
    static final String INPUT_LOG = "Input: %s (%s)";    
    static final String OUTPUT_LOG = "Output: %s (%s)";

    static boolean DEBUG = false;

    static String VER = Util.getAppVersion();
    
    static final Options optionsInfo = new Options() {
        {
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(true)
                    .build());
        }
    };
    
    static final Options optionsSVG = new Options() {
        {
            addOption(Option.builder("x")
                    .longOpt("xml")
                    .desc("Express Imagemap XML file")
                    .hasArg()
                    .required()
                    .build());
            addOption(Option.builder("i")
                    .longOpt("image")
                    .desc("Image file (.gif, .jpg, .png, etc.)")
                    .hasArg()
                    .required()
                    .build());
            addOption(Option.builder("s")
                    .longOpt("svg")
                    .desc("resulted SVG map file or folder")
                    .hasArg()
                    .required(false)
                    .build());
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(false)
                    .build());            
        }
    };
    
    static final Options optionsSVGscope = new Options() {
        {
            addOption(Option.builder("svg")
                    .longOpt("svg")
                    .desc("generate SVG files")
                    .hasArg(false)
                    .required()
                    .build());   
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(false)
                    .build());            
        }
    };

    static final Options options = new Options() {
        {
            addOption(Option.builder("o")
                    .longOpt("output")
                    .desc("output file name")
                    .hasArg()
                    .required(false)
                    .build());
            addOption(Option.builder("b")
                    .longOpt("boilerplatepath")
                    .desc("path to boilerplate text storage folder")
                    .hasArg()
                    .required(false)
                    .build());
            addOption(Option.builder("v")
                    .longOpt("version")
                    .desc("display application version")
                    .required(false)
                    .build());            
        }
    };

    static final String USAGE = getUsage();

    static final int ERROR_EXIT_CODE = -1;

    static final String TMPDIR = System.getProperty("java.io.tmpdir");
    
    static final Path tmpfilepath  = Paths.get(TMPDIR, UUID.randomUUID().toString());
    
    String resourcePath = "";
    
    String boilerplatePath = "";
    
    /**
     * Main method.
     *
     * @param args command-line arguments
     * @throws org.apache.commons.cli.ParseException
     */
    public static void main(String[] args) throws ParseException {

        CommandLineParser parser = new DefaultParser();
               
        boolean cmdFail = false;
        
        try {
            CommandLine cmdInfo = parser.parse(optionsInfo, args);
            printVersion(cmdInfo.hasOption("version"));            
        } catch (ParseException exp) {
            cmdFail = true;
        }
        
        if(cmdFail) {
            try {
                CommandLine cmd = parser.parse(optionsSVG, args);
                System.out.print("stepmod2mn ");
                printVersion(cmd.hasOption("version"));
                
                String xmlIn = cmd.getOptionValue("xml");
                String imageIn = cmd.getOptionValue("image");
                //get filename from path
                imageIn = Paths.get(imageIn).getFileName().toString();

                try {
                    stepmod2mn app = new stepmod2mn();
                    app.generateSVG(xmlIn, imageIn, cmd.getOptionValue("svg"));
                    System.out.println("End!");

                } catch (Exception e) {
                    e.printStackTrace(System.err);
                    System.exit(ERROR_EXIT_CODE);
                }
                cmdFail = false;
            } catch (ParseException exp) {
                cmdFail = true;
            }
        }
        
        if(cmdFail) {
            try {
                CommandLine cmd = parser.parse(optionsSVGscope, args);
                System.out.print("stepmod2mn ");
                printVersion(cmd.hasOption("version"));
                
                List<String> arglist = cmd.getArgList();
                
                String argPathIn = arglist.get(0);
                
                if (!Files.exists(Paths.get(argPathIn))) {                   
                    System.out.println(String.format(INPUT_PATH_NOT_FOUND, XML_INPUT, argPathIn));
                    System.exit(ERROR_EXIT_CODE);
                }

                try {
                    stepmod2mn app = new stepmod2mn();
                    app.generateSVG(argPathIn, null, null);
                    System.out.println("End!");

                } catch (Exception e) {
                    e.printStackTrace(System.err);
                    System.exit(ERROR_EXIT_CODE);
                }
                cmdFail = false;
                
            } catch (ParseException exp) {
                cmdFail = true;
            }
        }
        
        if(cmdFail) {            
            try {             
                CommandLine cmd = parser.parse(options, args);
                
                System.out.print("stepmod2mn ");
                /*if(cmd.hasOption("version")) {                    
                    System.out.print(VER);
                }                
                System.out.println("\n");*/

                printVersion(cmd.hasOption("version"));
                
                List<String> arglist = cmd.getArgList();
                if (arglist.isEmpty() || arglist.get(0).trim().length() == 0) {
                    throw new ParseException("");
                }
                
                String argXMLin = arglist.get(0);
                
                String resourcePath = "";

                String format = "adoc";
                String outFileName = "";
                if (cmd.hasOption("output")) {
                    outFileName = cmd.getOptionValue("output");
                }

                String boilerplatePath = "";
                if (cmd.hasOption("boilerplatepath")) {
                    boilerplatePath = cmd.getOptionValue("boilerplatepath") + File.separator;
                }
                
                // if remote file (http or https)
                if (argXMLin.toLowerCase().startsWith("http") || argXMLin.toLowerCase().startsWith("www.")) {

                    if (!Util.isUrlExists(argXMLin)) {
                        System.out.println(String.format(INPUT_NOT_FOUND, XML_INPUT, argXMLin));
                        System.exit(ERROR_EXIT_CODE);
                    }

                    resourcePath = Util.getParentUrl(argXMLin);

                    if (!cmd.hasOption("output")) {
                        outFileName = Paths.get(System.getProperty("user.dir"), Util.getFilenameFromURL(argXMLin)).toString();
                    }

                    /*
                    //download to temp folder
                    //System.out.println("Downloading " + argXMLin + "...");
                    String urlFilename = new File(url.getFile()).getName();                    
                    InputStream in = url.openStream();                    
                    Path localPath = Paths.get(tmpfilepath.toString(), urlFilename);
                    Files.createDirectories(tmpfilepath);
                    Files.copy(in, localPath, StandardCopyOption.REPLACE_EXISTING);
                    //argXMLin = localPath.toString();
                    System.out.println("Done!");*/
                } else { // in case of local file
                    String argXMLin_normalized = argXMLin;
                    if (argXMLin_normalized.startsWith("./") || argXMLin_normalized.startsWith(".\\")) {
                        argXMLin_normalized = argXMLin_normalized.substring(2);
                    }
                    File fXMLin = new File(argXMLin_normalized);
                    fXMLin = fXMLin.getAbsoluteFile();
                    System.out.println("fXMLin=" + fXMLin.toString());
                    if (!fXMLin.exists()) {
                        System.out.println(String.format(INPUT_NOT_FOUND, XML_INPUT, fXMLin));
                        System.exit(ERROR_EXIT_CODE);
                    }

                    //parent path for input resource.xml
                    //resourcePath = new File(argXMLin).getParent() + File.separator;
                    resourcePath = fXMLin.getParent() + File.separator;
                    System.out.println("resourcePath=" + resourcePath);

                    if (!cmd.hasOption("output")) { // if local file, then save result in input folder
                      outFileName = fXMLin.getAbsolutePath();
                    }                    
                }

                if (!cmd.hasOption("output")) {
                    outFileName = outFileName.substring(0, outFileName.lastIndexOf('.') + 1);
                    outFileName = outFileName + format;
                }

                File fileOut = new File(outFileName);

                /*DEBUG = cmd.hasOption("debug"); */

                System.out.println(String.format(INPUT_LOG, XML_INPUT, argXMLin));                
                System.out.println(String.format(OUTPUT_LOG, format.toUpperCase(), fileOut));
                System.out.println();

                try {
                    stepmod2mn app = new stepmod2mn();
                    app.setResourcePath(resourcePath);
                    app.setBoilerplatePath(boilerplatePath);
                    app.convertstepmod2mn(argXMLin, fileOut);                    
                    System.out.println("End!");

                } catch (Exception e) {
                    e.printStackTrace(System.err);
                    System.exit(ERROR_EXIT_CODE);
                }
                cmdFail = false;
                //}
            } catch (ParseException exp) {
                cmdFail = true;            
            }
        }
        
        // flush temporary folder
        if (!DEBUG) {
            Util.FlushTempFolder(tmpfilepath);
        }
        
        if (cmdFail) {
            System.out.println(USAGE);
            System.exit(ERROR_EXIT_CODE);
        }
    }

    //private void convertstepmod2mn(File fXMLin, File fileOut) throws IOException, TransformerException, SAXParseException {
    private void convertstepmod2mn(String xmlFilePath, File fileOut) throws IOException, TransformerException, SAXParseException {
        
        System.out.println("Transforming...");
        
        try {
            
            Source srcXSL = null;
            
            String bibdataFileName = fileOut.getName();
            
            // get linearized XML with default attributes substitution from DTD
            String linearizedXML = processLinearizedXML(xmlFilePath);
            
            // load linearized xml
            Source src = new StreamSource(new StringReader(linearizedXML));
            ClassLoader cl = this.getClass().getClassLoader();
            String systemID = "stepmod2mn.adoc.xsl";
            //InputStream in = cl.getResourceAsStream(systemID);
            URL url = cl.getResource(systemID);
            
            srcXSL = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), systemID));//"stepmod2mn.adoc.xsl"
            srcXSL.setSystemId(url.toExternalForm());
            
            TransformerFactory factory = TransformerFactory.newInstance();
            factory.setURIResolver(new ClasspathResourceURIResolver());            
            Transformer transformer = factory.newTransformer();
            
            Templates cachedXSLT = factory.newTemplates(srcXSL);
            //transformer = factory.newTransformer(srcXSL);
            transformer = cachedXSLT.newTransformer();
            
            transformer.setParameter("docfile", bibdataFileName);
            transformer.setParameter("pathSeparator", File.separator);
            transformer.setParameter("path", resourcePath);
            String outputPath = fileOut.getParent();
            if (outputPath == null) {
                outputPath = System.getProperty("user.dir");
            }
            transformer.setParameter("outpath", outputPath);
            transformer.setParameter("boilerplate_path", boilerplatePath);

            transformer.setParameter("debug", DEBUG);

            StringWriter resultWriter = new StringWriter();
            StreamResult sr = new StreamResult(resultWriter);

            transformer.transform(src, sr);
            String adoc = resultWriter.toString();

            File adocFileOut = fileOut;
            
            try (Scanner scanner = new Scanner(adoc)) {
                String outputFile = adocFileOut.getAbsolutePath();
                StringBuilder sbBuffer = new StringBuilder();
                while (scanner.hasNextLine()) {
                    String line = scanner.nextLine();                    
                    sbBuffer.append(line);
                    sbBuffer.append(System.getProperty("line.separator"));
                }
                writeBuffer(sbBuffer, outputFile);
            }
            System.out.println("Saved " + Util.getFileSize(adocFileOut) + " bytes.");
            
        } catch (SAXParseException e) {            
            throw (e);
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(ERROR_EXIT_CODE);
        }
    }
    
    class ClasspathResourceURIResolver implements URIResolver {
        public Source resolve(String href, String base) throws TransformerException {
          return new StreamSource(getClass().getClassLoader().getResourceAsStream(href));
        }
    }
    
    private void writeBuffer(StringBuilder sbBuffer, String outputFile) throws IOException {
        try (BufferedWriter writer = Files.newBufferedWriter(Paths.get(outputFile))) {
            writer.write(sbBuffer.toString());
        }
        sbBuffer.setLength(0);
    }
    private static String getUsage() {
        StringWriter stringWriter = new StringWriter();
        PrintWriter pw = new PrintWriter(stringWriter);
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp(pw, 80, CMD, "", options, 0, 0, "");
        pw.write("\nOR\n\n");
        formatter.printHelp(pw, 80, CMD_SVGscope, "", optionsSVGscope, 0, 0, "");
        pw.write("\nOR\n\n");
        formatter.printHelp(pw, 80, CMD_SVG, "", optionsSVG, 0, 0, "");
        pw.flush();
        return stringWriter.toString();
    }

    private static void printVersion(boolean print) {
        if (print) {            
            System.out.println(VER);
        }
    }       

    public void setResourcePath(String resourcePath) {
        this.resourcePath = resourcePath;
    }
    
    public void setBoilerplatePath(String boilerplatePath) {
        this.boilerplatePath = boilerplatePath;
    }
    
    private String processLinearizedXML(String xmlFilePath){
        try {
            InputStream xmlInputStream = null;

            File fXMLin = new File(xmlFilePath);

            if (xmlFilePath.toLowerCase().startsWith("http") || xmlFilePath.toLowerCase().startsWith("www.")) {
                try {
                    URL url = new URL(xmlFilePath);
                    xmlInputStream = url.openStream();
                } catch (IOException ex) {} //checked above


            } else { try {
                // in case of local file
                xmlInputStream = new FileInputStream(fXMLin);
                } catch (FileNotFoundException ex) { }//checked above
            }

            // to skip validating 
            //found here: https://moleshole.wordpress.com/2009/10/08/ignore-a-dtd-when-using-a-transformer/
            XMLReader rdr = XMLReaderFactory.createXMLReader();

            /*rdr.setEntityResolver(new EntityResolver() {
                @Override
                public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
                    if (systemId.endsWith(".dtd")) {
                            //StringReader stringInput = new StringReader(" ");
                            StringReader stringInput = new StringReader(systemId);
                            //StringReader stringInput = new StringReader("file:///C:/Delete/test.dtd");
                            //return new InputSource(stringInput);
                            String dtd = "C:/Delete/test.dtd";
                            return new InputSource(new FileInputStream(dtd));
                    }
                    else {
                            return null; // use default behavior
                    }
                }
            });*/

            TransformerFactory factory = TransformerFactory.newInstance();
            factory.setURIResolver(new ClasspathResourceURIResolver());            
            Transformer transformer = factory.newTransformer();
            //Source src = new StreamSource(fXMLin);
            //Source src = new SAXSource(rdr, new InputSource(new FileInputStream(fXMLin)));
            InputSource is = new InputSource(xmlInputStream);
            is.setSystemId(xmlFilePath);
            Source src = new SAXSource(rdr, is);
            //Source src = new StreamSource(is);

            // linearize XML
            Source srcXSLidentity = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "linearize.xsl"));

            transformer = factory.newTransformer(srcXSLidentity);

            StringWriter resultWriteridentity = new StringWriter();
            StreamResult sridentity = new StreamResult(resultWriteridentity);
            transformer.transform(src, sridentity);
            String xmlidentity = resultWriteridentity.toString();
            return xmlidentity;
        } catch (Exception e) {
            e.printStackTrace(System.err);
            System.exit(ERROR_EXIT_CODE);
        }
        return "";
    }
    
    private void generateSVG(String xmlFilePath, String image, String outPath) throws IOException, TransformerException, SAXParseException {
        List<String> xmlFiles;
        String extension = ".xml";
        try (Stream<Path> walk = Files.walk(Paths.get(xmlFilePath))) {
            xmlFiles = walk
                .filter(p -> !Files.isDirectory(p))   
                .map(p -> p.toString())
                .filter(f -> f.toLowerCase().endsWith(extension))
                .collect(Collectors.toList());
        }
        for(String xmlFile: xmlFiles) {
            try
            {
                String content = new String(Files.readAllBytes(Paths.get(xmlFile)));
                if (content.contains("img.area"))  {
                    String folder = new File(xmlFile).getParent() + File.separator;
                    String svgFilename = xmlFile.substring(0, xmlFile.length() - extension.length()) + ".svg";
                    if (outPath != null && !outPath.isEmpty()) {
                        if (!(outPath.toLowerCase().endsWith(".svg") || outPath.toLowerCase().endsWith(".xml"))) { // if folder
                            Files.createDirectories(Paths.get(outPath));
                            svgFilename = Paths.get(xmlFile).getFileName().toString();
                            svgFilename = svgFilename.substring(0, svgFilename.length() - extension.length()) + ".svg";
                            svgFilename = Paths.get(outPath, svgFilename).toString();
                        } else {
                            svgFilename = outPath;
                            String parentFolder = new File(svgFilename).getParent();
                            if (parentFolder != null && !parentFolder.isEmpty()) {
                                Files.createDirectories(Paths.get(parentFolder));
                            }
                        }    
                    }
                    System.out.println("Generate SVG file for " + xmlFile + "...");
                    
                    
                    // get linearized XML with default attributes substitution from DTD
                    String linearizedXML = processLinearizedXML(xmlFile);
                    // load linearized xml
                    Source src = new StreamSource(new StringReader(linearizedXML));
                    
                    Source srcXSL = new StreamSource(Util.getStreamFromResources(getClass().getClassLoader(), "map2svg.xsl"));
                    
                    TransformerFactory factory = TransformerFactory.newInstance();
                    Transformer transformer = factory.newTransformer();
                    transformer = factory.newTransformer(srcXSL);

                    transformer.setParameter("path", folder);
                    if (image != null) {
                        transformer.setParameter("image", image);
                    }
                    
                    StringWriter resultWriter = new StringWriter();
                    StreamResult sr = new StreamResult(resultWriter);

                    transformer.transform(src, sr);
                    String xmlSVG = resultWriter.toString();
                    try ( 
                        BufferedWriter writer = Files.newBufferedWriter(Paths.get(svgFilename))) {
                            writer.write(xmlSVG);                    
                    }
                }
            } 
            catch (Exception e) 
            {
                e.printStackTrace();
            }
        }
        //xmlFiles.forEach(x -> System.out.println(x));
    }
}
