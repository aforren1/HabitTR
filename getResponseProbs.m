function presponse = getResponseProbs(RT,params,model)
% returns response probabilities (correct, habit, error) given RTs and
% parameters
paramsA = params(1:3);
paramsB = params(4:6);
initAE = params(7);

PhiA = normcdf(RT,paramsA(1),paramsA(2)); % probability that A has been planned by RT
PhiB = normcdf(RT,paramsB(1),paramsB(2));

qA = paramsA(3);
qB = paramsB(3);

alpha = zeros(5,4);

switch(model)
    % set up parameters:
    %     p(r) = alpha(.,1)*(1-PhiA)*(1-PhiB) + alpha(.,2)*PhiA*(1-PhiB) +
    %     alpha(.,3)*(1-PhiA)*PhiB + alpha(.,4)*PhiA*PhiB

    
    case 'habit'
        alpha(1,:) = [initAE (1-qA)/3 qB qB]; % mapping B (correct)
        alpha(2,:) = [initAE qA (1-qB)/3 (1-qB)/3]; % mapping A (habit)
        alpha(3,:) = [.5-initAE (1-qA)/3 (1-qB)/3 (1-qB)/3]; % other responses
        alpha(4,:) = [initAE qA initAE qA]; % mapping A, no-conflict
        alpha(5,:) = [initAE initAE qB qB]; % mapping B, no-conflict
        
    case 'no-habit'
        alpha(1,:) = [initAE initAE qB qB]; % mapping B (correct)
        alpha(2,:) = [initAE initAE (1-qB)/3 (1-qB)/3]; % mapping A (habit)
        alpha(3,:) = [.5-initAE .5-initAE (1-qB)/3 (1-qB)/3]; % other responses
        alpha(4,:) = [initAE qA initAE qA]; % mapping A, no-conflict
        alpha(5,:) = [initAE initAE qB qB]; % mapping B, no-conflict
        
    case 'flex-habit'
        rho = params(8);
        alpha(1,:) = [initAE rho*(1-qA)/3+(1-rho)*initAE qB qB]; % mapping B (correct)
        alpha(2,:) = [initAE rho*qA+(1-rho)*initAE (1-qB)/3 (1-qB)/3]; % mapping A (habit)
        alpha(3,:) = [.5-initAE rho*(1-qA)/3+(1-rho)*(.5-initAE) (1-qB)/3 (1-qB)/3]; % other responses
        alpha(4,:) = [initAE qA initAE qA]; % mapping A, no-conflict
        alpha(5,:) = [initAE initAE qB qB]; % mapping B, no-conflict

    otherwise disp('No such case - Use habit, no-habit, or flex-habit')
end
        
%for i=1:5
%    presponse(i,:) = alpha(i,1)*(1-PhiA).*(1-PhiB) + alpha(i,2)*PhiA.*(1-PhiB) + alpha(i,3)*(1-PhiA).*PhiB + alpha(i,4)*PhiA.*PhiB;
%end
Phi = [(1-PhiA).*(1-PhiB); PhiA.*(1-PhiB); (1-PhiA).*PhiB; PhiA.*PhiB];
presponse = alpha*Phi;