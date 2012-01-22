class MtgCard < ActiveRecord::Base
  belongs_to :set, :class_name => "MtgSet"
  
end


!(/\.(?!htaccess)[^/]*|\.(tmproj|o|pyc)|/Icon\r|/svn-commit(\.[2-9])?\.tmp)$

!.*/(\.[^/]*|CVS|_darcs|_MTN|\{arch\}|blib|.*~\.nib|.*\.(framework|app|pbproj|pbxproj|xcode(proj)?|bundle))$