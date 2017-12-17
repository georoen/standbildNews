# heuteZensiert

## Hintergrund

Seit der Einführung des neuen Rundfunkbeitrags am 1.1.2013, ehemals GEZ, zahlen deutsche Haushalte einen geräteunabhängigen Beitrag. TV, Radio und Internet wurden hier gleichgestellt. 

> Die Angebote von ARD, ZDF und Deutschlandradio lassen sich heute auf verschiedenen Wegen empfangen – ob über Radio, Fernseher, Computer oder Smartphone.  
> -- [Faktenblatt von www.rundfunkbeitrag.de](https://www.rundfunkbeitrag.de/e175/e224/Faktenblatt_zum_neuen_Rundfunkbeitrag.pdf) vom 29.11.2012

Doch dies trifft nicht auf die gesamten Inhalte zu. Allzuhäufig sind im Online-Angebot der öffentlich-rechtlichen Rundfunkanstalten Banner zu sehen, welche darauf hinweisen, dass bestimmte Inhalte nicht im Internet gezeigt werden können. So lautet die Information auf dem Standbild der Tagesschau

![Kurze Unterbrechung - Diese Bilder dürfen aus rechtlichen Gründen nicht im Internet gezeigt werden](extra/Twitter.png)

Dieses Projekt beschäftigt sich im Speziellen mit den abendlichen Nachrichtensendungen von ARD und ZDF.

Die von der Zensur betroffenen Themenbereiche sind zumeist der Sportteil, aber auch andere Abschnitte können betroffen sein. Welche Inhalte online verfügbar sind und welche nicht, ist für den Endnutzer nicht nachvollziehbar. Es ist anzunehmen, dass es die von Dritten angekaufen Videosequenzen sind. Doch eigentlich müssten die Sender, wenn sie den neuen Rundfunkbeitrag verwenden, sich bei Verträgen mit Dritten für alle Beitragszahler gleichmäßig einsetzen. Ausstrahlungsverträge einzelner Inhalte, welche lediglich die TV-Ausstrahlung zulassen, dürften nicht abgeschlossen werden.

## Ziel von heuteZensiert

Das Ziel des Projektes ist eine strukturierte, standardisierte und transparente Auswertung von bürgerfinanzierten Medieninhalten. So soll datengetriebene Kritik an öffentlich-rechtlichen Rundfunkanstalten geübt und eine Diskussionsgrundlage geschaffen werden, um die Medienlanschaft in Deutschland zu reformieren. 

**TV und Online - wir zahlen das Gleiche, wir wollen das Gleiche sehen.**

# heuteStatistik
Um den genauen Anteil der nicht ausgestrahlen Nachrichtensendungen zu erfassen, werden *ZDF heute 19 Uhr*, *ZDF heute Journal* und *ARD Tagesschau* automatisch online gestreamt. Ein *R* Programm erkennt dann mithilfe von [Texterkennungssoftware](https://github.com/ropensci/tesseract) die blockierten Frames. Anschließend veröffentlicht dieser [Twitter-Bot](https://twitter.com/heuteNichtDrin) das Ergebnis. *Digital natives* können diesem followen, um sich vorab informieren zu lassen, welche Nachrichtensendung vollständig ist und sie gerne sehen möchten. 

Die so erhoben Daten werden abschließend in einer [Tabelle](Logfile.csv) gespeichert. Das nachfolgende Widget ([Shiny-App](https://jeremybz.shinyapps.io/heuteZensiert/)) greift diese auf, um die Ausstrahlungspraxis zu analysieren:


<iframe src="https://heutezensiert.shinyapps.io/heuteZensiert/" style='width: 1px;min-width: 100%;height: 500px' frameborder="0"></iframe>  

Es zeigt sich, dass alle Sender ihre Nachrichtensendungen bearbeiten, bevor sie diese (mit blockierten Szenen) ins Netz laden. Da die Nachrichten online zeitgleich (oder gar später) ausgestrahlt werden, hat der digitalen Nachrichtenschauer keine Möglichkeit mehr die blockierten Passagen im TV nachzuschauen. 

Digital-Natives sind besonders betroffen und im Vergleich zu konventionellen Nutzern schlechter informiert. In Zeiten steigender Popularität von Internetstreaming-Angeboten ([ARD/ZDF-Onlinestudie, 2017](http://www.ard-zdf-onlinestudie.de/ardzdf-onlinestudie-2017/)) ist es an der Zeit, die geänderten Nutzungsgewohnheiten anzuerkennen und die Rechtepolitik anzupassen. Wir möchten User und Politik aufrufen, den Druck auf die öffentlich-rechtlichen Rundfunkanstalten zu erhöhen und [ARD](mailto:info@DasErste.de) und [ZDF](mailto:zuschauerredaktion@zdf.de) zu mailen. Gleiche Leistung für gleichen Rundfunkbeitrag!

---

> [Installieren](Install.md) | [Mitmachen](Mitmachen.md) | [Disclaimer](Disclaimer.md)
