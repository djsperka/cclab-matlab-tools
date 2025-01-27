mst = OneShotMilestone([.25,.5,.75]);

msg = {'First milestone at 0.25...', 'Second milestone at 0.5', 'Third milestone at 0.75'};
itrial = 1;
ntrials = 100;
while itrial < ntrials
    if mst.check(itrial/ntrials)
        ind = mst.pass(itrial/ntrials);
        fprintf('Trial#: %d/%d: %s\n', itrial, ntrials, msg{ind});
    end
    itrial = itrial+1;
end





mst = OneShotMilestone([24,55,80]);

msg = {'First milestone at 24', 'Second milestone at 55', 'Third milestone at 80'};
itrial = 1;
ntrials = 100;
while itrial < ntrials
    if mst.check(itrial)
        ind = mst.pass(itrial);
        fprintf('Trial#: %d/%d: %s\n', itrial, ntrials, msg{ind});
    end
    itrial = itrial+1;
end