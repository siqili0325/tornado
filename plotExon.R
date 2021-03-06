plotExon <-
function(getRegionObject, ind=NULL, exonname=NULL, tstats, pos, annotation, counts, group, bppad = 50, axpad = 50, prettyskips = T, skiplines = T, countsheader=F, countssep="\t", tabname = NULL, plotfile = NULL, width = 900, height = 750, plottitle = NULL, chromosome,legendloc="bottomleft")
{
	if(!all(c("states.norle","states") %in% names(getRegionObject))) stop("getRegionObject must be a list with elements \"states.norle\" and \"states\" - usually the return of getRegions()")
	if(!all(c("chr","start","end") %in% names(getRegionObject$states))) stop("getRegionObject \"states\" component must contain chr, start, and end")
	if(!all(c("chr","start","end")%in%colnames(annotation))) stop("annotation must contain columns named chr, start, and end")
	if(!("name" %in% colnames(annotation))) stop("annotation must contain column called name, denoting exon name")
	if(is.null(ind) & is.null(exonname)) stop("must provide exactly one of ind and exonname")
	if(!is.null(ind) & !is.null(exonname)) stop("must provide exactly one of ind and exonname")
	if(is.null(ind)) ind = which(annotation$name == exonname)
	if(is.null(exonname)) exonname = as.character(unique(annotation$name[ind]))
	if(length(exonname)>1) stop("exonname must have length 1. possible cause: ind spans multiple exons.")
	chr = unique(annotation$chr[ind])
	if(chr!=chromosome) stop("chromosome label in annotation does not match provided chromosome. please double check.")
	if(length(chr)>1) stop("exon name not unique across chromosomes, please check annotation")
	Start = min(annotation$start[ind])
	End = max(annotation$end[ind])
	if(sum(sort(pos)!=pos)>0) stop("pos improperly sorted")
	if(!prettyskips) stop("I haven't implemented this without prettyskips yet - sorry!")
	print(c("ind:",ind),quote=F)
	print(paste("exon name: ",exonname),sep="")
	
	if(is.character(counts)){
		if(substr(counts,nchar(counts)-2,nchar(counts))==".db"){
			require(Genominator)
			if(is.null(tabname)) stop("reading matrix from database requires table name")
			counts <- ExpData(dbFilename = counts, tablename = tabname)
		}else{
		warning("Reading count matrix from file. May take several minutes and/or exceed memory limits.")
		counts <- read.table(counts,header=countsheader,sep=countssep)
		}
	}
		
	# other choice: counts can be an already-loaded matrix
	
	lowerbound = Start-bppad
	upperbound = End+bppad
	xaxinds = which(pos>=lowerbound & pos<=upperbound)
	plotlb = xaxinds[1]-axpad
	plotub = xaxinds[length(xaxinds)]+axpad
	
	if(!is.null(plotfile)) jpeg(file=plotfile,width=width,height=height)
	
	par(mar=c(1,3.2,2,1),mgp=c(1.5,0.5,0),mfrow=c(3,1),cex.lab=1.5,omi=c(0.4,0,0,0))
	
	## panel A: plots of raw data
	groupsplit = split(1:length(group),group)
	if(length(groupsplit)!=2) stop("need exactly 2 comparison groups")
	g1 = groupsplit[[1]]
	g2 = groupsplit[[2]]
	firstcolor = ifelse(1 %in% groupsplit[[1]],"blue","red")
	k = ifelse(class(counts)=="ExpData",2,1)
	plot(xaxinds,log2(as.matrix(counts[xaxinds,k]+0.5)),type="l",lwd=0.5,col=firstcolor,ylim=c(-2,9),xaxt="n",
		xlim=c(plotlb,plotub),xlab="",ylab="log2 count")
	if(class(counts)=="ExpData") {g1 = g1+1; g2 = g2+1} #account for pos column
	for(i in g1){
  		lines(xaxinds,log2(as.matrix(counts[xaxinds,i]+0.5)),type="l",lwd=0.5,col="blue")
	}
	for(i in g2){
  		lines(xaxinds,log2(as.matrix(counts[xaxinds,i]+0.5)),type="l",lwd=0.5,col="red")
	}
	mean1 = rowMeans(log2(counts[xaxinds,g1]))
	mean2 = rowMeans(log2(counts[xaxinds,g2]))
	lines(xaxinds,mean1,col="blue",lwd=3)
	lines(xaxinds,mean2,col="red",lwd=3)
	if(is.null(plottitle)) plottitle = paste(chromosome,": ",Start,"-",End,", exon ",exonname,sep="")
	title(plottitle,cex.main=2)
	legend(legendloc,names(groupsplit),lty=c(1,1),col=c("blue","red"))
	if(skiplines){
		for(i in which(diff(pos)[xaxinds]!=1)[-length(which(diff(pos)[xaxinds]!=1))]){
		   abline(v=xaxinds[i],lwd=0.5,col="black")}
	}
	

	## panel B: plots of t-statistics
	plot(xaxinds,tstats[xaxinds],type="l",col="gray39",lwd=3,xaxt="n",xlim=c(plotlb,plotub),xlab="",ylab="")
	title(ylab="t statistic",mgp=c(1.5,1,0.2))
	abline(h=0,lty=2)
	if(skiplines){
		for(i in which(diff(pos)[xaxinds]!=1)[-length(which(diff(pos)[xaxinds]!=1))]){
		   abline(v=xaxinds[i],lwd=0.5,col="black")}
	}
	
	
	## panel C: annotated exons and state calls.
	#setup
	plot(xaxinds,rep(0,length(xaxinds)),type="n",ylim=c(-.5,.5),yaxt="n",ylab="",xlim=c(plotlb,plotub),xaxt="n")
	#exons
	theExons = annotation[ind,]
	for(i in ind){
		exonend <- which(pos==annotation$end[i])
		exonstart <- which(pos==annotation$start[i])
		if(length(exonend)==0) {
			exonend <- which(pos<=annotation$end[i])[length(which(pos<=annotation$end[i]))]
			warning(paste("exon end position not in pos. Actual end: ",annotation$end[i],", marked end: ", pos[exonend],sep=""))
		}
		if(length(exonstart)==0){
			exonstart <- which(pos>=annotation$start[i])[1]
			warning(paste("exon start position not in pos. Actual start: ",annotation$start[i],", marked start: ", pos[exonstart],sep=""))
		}
		polygon(x=c(rep(exonstart,2),rep(exonend,2)), y=c(-.1,-.4,-.4,-.1), col="purple3")
	} # end plotting of exons
	#states
	for(k in 1:length(xaxinds)){
		if(getRegionObject$states.norle$state[xaxinds][k]==1) thecolor <- "gray"
		if(getRegionObject$states.norle$state[xaxinds][k]==2) thecolor <- "black"
		if(getRegionObject$states.norle$state[xaxinds][k]==3) thecolor <- "red"
		if(getRegionObject$states.norle$state[xaxinds][k]==4) thecolor <- "green"
		lines(rep(xaxinds[k],2),c(.1,.4),col=thecolor,lwd=2)
	} # end plotting of states
	axis(2,at=c(-.25,.25),labels=c("exons","states"),cex.axis=1.5)
	axsize = ifelse(is.null(plotfile),1.5,2)
	axis(1,at=xaxinds[seq(1,length(xaxinds),by=100)],labels=pos[xaxinds[seq(1,length(xaxinds),by=100)]],cex.axis=axsize)
	title(xlab="genomic position",outer=TRUE)
	if(skiplines){
		for(i in which(diff(pos)[xaxinds]!=1)[-length(which(diff(pos)[xaxinds]!=1))]){
		   abline(v=xaxinds[i],lwd=0.5,col="black")}
	}
	
	if(!is.null(plotfile)) dev.off()
}
