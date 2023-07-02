# Entre com o objeto fit.model de um ajuste da regressao gama.  
# A saida sera o grafico de envelope para o residuo componente 
# do desvio padronizado. 
# Para  usar  outras  ligacoes mudar o argumetno de entrada family1:
# - log: family=Gamma(link=log)
# - reciproca: family=Gamma  # canonica, por default
# - identidade: family= Gamma(link=identity)

envelope.gamalog<-function(fit.model,family1=Gamma(link = "log"))
{
  par(mfrow=c(1,1))
  X <- model.matrix(fit.model)
  n <- nrow(X)
  p <- ncol(X)
  w <- fit.model$weights
  W <- diag(w)
  H <- solve(t(X)%*%W%*%X)
  H <- sqrt(W)%*%X%*%H%*%t(X)%*%sqrt(W)
  h <- diag(H)
  ro <- resid(fit.model,type="response")
  fi <- (n-p)/sum((ro/(fitted(fit.model)))^ 2)
  td <- resid(fit.model,type="deviance")*sqrt(fi/(1-h))
  #
  e <- matrix(0,n,100)
  #
  i<-0
  #for(i in 1:100)
  while(i < 100)
  {
    resp <- rgamma(n,fi)
    resp <- (fitted(fit.model)/fi)*resp
    #fit <- glm(resp ~ X, family=family1)
    
    fit <- try(glm(resp ~ X, family=family1),silent=T)
    
    if(class(fit)[1] == "try-error")
    {
      convergencia<-FALSE
      print(c("ERROR",convergencia),quote=F)
    }else{
      convergencia<-fit$converged  
    }
    if(convergencia==T)
    {
      i<-i+1
      
      w <- fit$weights
      W <- diag(w)
      H <- solve(t(X)%*%W%*%X)
      H <- sqrt(W)%*%X%*%H%*%t(X)%*%sqrt(W)
      h <- diag(H)
      ro <- resid(fit,type="response")
      phi <- (n-p)/sum((ro/(fitted(fit)))^ 2)
      e[,i] <- sort(resid(fit,type="deviance")*sqrt(phi/(1-h)))
    }
  }  
  #
  e1 <- numeric(n)
  e2 <- numeric(n)
  #
  for(i in 1:n){
    eo <- sort(e[i,])
    e1[i] <- (eo[2]+eo[3])/2
    e2[i] <- (eo[97]+eo[98])/2}
  #
  med <- apply(e,1,mean)
  faixa <- range(td,e1,e2)
  par(pty="s")
  qqnorm(td, xlab="Percentil da N(0,1)",
         ylab="Componente do Desvio", ylim=faixa, pch=16)
  par(new=T)
  #
  qqnorm(e1,axes=F,xlab="",ylab="",type="l",ylim=faixa,lty=1, cex=0.6)
  par(new=T)
  qqnorm(e2,axes=F,xlab="",ylab="", type="l",ylim=faixa,lty=1, cex=0.6)
  par(new=T)
  qqnorm(med,axes=F,xlab="", ylab="", type="l",ylim=faixa,lty=2, cex=0.6)
  #----------------------------------------------------------------#                      
}