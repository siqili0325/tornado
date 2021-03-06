getExons <-
function(region,annotation,verbose=TRUE) {
	if(!is.vector(region)) stop("region must be a vector (chr, start, end)")
	if(length(region)!=3) stop("region must be a vector of length 3 (chr, start, end)")
	chr = region[1]
	Start = as.numeric(region[2])
	End = as.numeric(region[3])
	
	if(!is.data.frame(annotation)) stop("annotation must be a data frame. see getAnnotation().")
	if(!all(c("chr","start","end")%in%colnames(annotation))) stop("annotation must contain columns named chr, start, and end")
	if(any(is.na(annotation[,c("chr","start","end")])) | any(is.na(region))) stop("No missing values allowed in chr, start, or end.")
	
	annotation = annotation[annotation$chr==chr,]
	annotation = annotation[order(annotation$start),]
	startswithin = which(annotation$start<=Start & annotation$end>=Start)
	endswithin = which(annotation$start<=End & annotation$end>=End)
	overlapswhole = which(annotation$start>=Start & annotation$end<=End)
	tmp = length(startswithin)+length(endswithin)+length(overlapswhole)
	inExon = ifelse(tmp==0,0,1)
	if(inExon==1) {
		if(verbose) print("region overlaps annotated exon(s)")
		out <- annotation[c(startswithin,endswithin),]
	}
	if(inExon==0) {
		if(verbose) print("region is not within an annotated exon, returning closest exon(s) on either side")
		rightdists <- abs(annotation$start-End)
		relevant.right.inds <- which(annotation$start>=End)
		right.tmp <- which.min(rightdists[relevant.right.inds])
		right.closest <- relevant.right.inds[right.tmp]
		leftdists <- abs(annotation$end - Start)
		relevant.left.inds <- which(annotation$end<=Start)
		left.tmp <- which.min(leftdists[relevant.left.inds])
		left.closest <- relevant.left.inds[left.tmp]
		closests <- c(left.closest,right.closest)
		out <- annotation[closests,]
		
	}
	
	return(list(region=region, closestExons=out))
}
