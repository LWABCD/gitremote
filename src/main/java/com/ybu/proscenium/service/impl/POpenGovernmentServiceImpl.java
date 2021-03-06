package com.ybu.proscenium.service.impl;

import com.ybu.entity.Opengovernment;
import com.ybu.entity.OpengovernmentExample;
import com.ybu.entity.Opengovtype;
import com.ybu.mapper.OpengovernmentMapper;
import com.ybu.mapper.OpengovtypeMapper;
import com.ybu.proscenium.service.POpenGovernmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class POpenGovernmentServiceImpl implements POpenGovernmentService{

    @Autowired
    private OpengovernmentMapper opengovernmentMapper;
    @Autowired
    private OpengovtypeMapper opengovtypeMapper;

    @Override
    public List<Opengovernment> openGovernments(Integer ogtid) {
        OpengovernmentExample example=new OpengovernmentExample();
        OpengovernmentExample.Criteria criteria=example.createCriteria();
        criteria.andOgtidEqualTo(ogtid);
        return opengovernmentMapper.selectByExampleWithBLOBs(example);
    }

    @Override
    public List<Opengovtype> openGovTypes() {
        return opengovtypeMapper.selectAllOpengovtype();
    }

    @Override
    public Opengovernment openGovDetail(Integer oid) {
        Opengovernment opengovernment=opengovernmentMapper.selectByPrimaryKey(oid);
        opengovernment.setReadnumber(opengovernment.getReadnumber()+1);
        opengovernmentMapper.updateByPrimaryKeyWithBLOBs(opengovernment);
        return opengovernment;
    }
}
