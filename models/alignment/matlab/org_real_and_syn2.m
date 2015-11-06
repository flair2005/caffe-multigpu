clear, close all
load model_brand_idx
load model_name_3d
load bbox_syn
len = length(model_name_3d);
realDir ='/home/ljyang/work/data/CompCars/image/';
labDir = '/home/ljyang/work/data/CompCars/label/';
synDir ='/home/ljyang/work/alignment/3d_models/car_models/obj/';
savDir ='/home/ljyang/work/data/real_and_syn/';
train_filename = ['../lists/transfer_train2'];
% test_filename = ['../lists/transfer_test'];
% syn_filename= ['../lists/transfer_syn'];
f_train = fopen(train_filename,'w');
% f_test = fopen(test_filename,'w');
% f_syn = fopen(syn_filename,'w');
pad = 0.07;
cls_id = -1;
syn_im = 180;
h_space = 6;
h_n = 360/h_space;
view_d_proj = [zeros(3,1);ones(10,1)*3;ones(5,1)*2;ones(10,1)*4;...
    ones(5,1);ones(10,1)*4;ones(5,1)*2;ones(10,1)*3;0;0];
for i=1:len
    if length(model_name_3d{i,2})>0
        cls_id = cls_id+1;
        cls_id
        model_id = model_name_3d{i,2};
        make_id = model_brand_idx(model_id);
        year = dir([realDir,num2str(make_id),'/',num2str(model_id)]);
        year = year(3:end);
        %no need to randperm
        for k=1:length(year)
            list = dir([realDir,num2str(make_id),'/',num2str(model_id),...
                '/',year(k).name,'/*.jpg']);
            for j=1:length(list)
%                 c=c+1;
                label = textread([labDir,num2str(make_id),'/',...
                    num2str(model_id),'/',year(k).name,'/',list(j).name(1:end-4),...
                    '.txt'],'%d');
                if label(1)>0 %valid viewpoint
%                     im =imread([realDir,num2str(make_id),'/',...
%                     num2str(model_id),'/',year(k).name,'/',list(j).name]);
%                     bbox = label(3:6);
%                     bbox_pad = gen_bbox_pad(im,bbox,pad,0);
%                     im_crop = im(bbox_pad(2):bbox_pad(4),bbox_pad(1):bbox_pad(3),:);
%                     imshow(im_crop);pause;
%                     if ~exist([savDir,'real/',num2str(model_id)],'dir');
%                         mkdir([savDir,'real/',num2str(model_id)]);
%                     end
                    im_path = [savDir,'real/',num2str(model_id),'/',list(j).name];
%                     imwrite(im_crop,im_path);
                    fprintf(f_train,'%s %d %d %d %d %d\n',im_path,0,-1,-1,-1,label(1)-1);
%                     fprintf(f_test,'%s %d %d %d %d %d\n',im_path,0,cls_id,-1,-1,label(1)-1);
                end
            end
        end
        for im_id = 1:syn_im
            im_path = [synDir,model_name_3d{i,1},'/',model_name_3d{i,1},...
                '_',num2str(im_id-1),'.png'];
            im_syn = imread(im_path);
            bbox = bbox_syn(i,im_id,:);
            bbox_pad = gen_bbox_pad(im_syn,bbox,pad,0);
            im_crop = im_syn(bbox_pad(2):bbox_pad(4),bbox_pad(1):bbox_pad(3),:);
            im_crop = double(im_crop)/255 - 0.57;
%             imshow(im_crop);pause;
            if ~exist([savDir,'syn/',num2str(model_id)],'dir');
                mkdir([savDir,'syn/',num2str(model_id)]);
            end
            im_path = [savDir,'syn/',num2str(model_id),'/',num2str(im_id-1),'.jpg'];
            imwrite(im_crop,im_path);
            view_h = mod(im_id-1,h_n);
            view_v = floor((im_id-1) / h_n);
            view_d = view_d_proj(view_h+1); 
            fprintf(f_train,'%s %d %d %d %d %d\n',im_path,1,cls_id,view_h,view_v,view_d);
%             fprintf(f_syn,'%s %d %d %d %d %d\n',im_path,1,cls_id,view_h,view_v,view_d);
        
        end
    end
end
% fclose(f_syn);
fclose(f_train);
% fclose(f_test);