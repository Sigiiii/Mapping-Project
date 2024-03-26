%% Plotting Std
function std_plot(y)
    std_las = std(y(1));
    std_mas = std(y(2));
    x = 1:1200;
    plot(x,y);
    hold on;
    fill([x,fliplr(x)],[y + std_las, fliplr(y - std_las)],'b','FaceAlpha',0.3,'EdgeColor','none');
    fill([x,fliplr(x)],[y + std_mas, fliplr(y - std_mas)],'b','FaceAlpha',0.3,'EdgeColor','none');
    legend('LAS','MAS');
    xlabel('frames');
    ylabel('degrees');
    title('Mean Position Curve');
end    

function Velocity(x,y,z)
    f2 = figure('Name','Velocity')
    plot(y);
    hold on;
    scatter(x.Var1,y(x.Var1),100,'r','filled');
    scatter(z{:,6},omega(z{:,6}),100,'y','filled');
    scatter(x.Var3,y(x.Var3),100,'g','filled');
    xlabel('frames');
    ylabel('velocity [ °/s ]');
    title('Velocity');
    legend('Angular Velocity','Auditory Stimulus','Kinematic Onset','EMG Onset');
end    